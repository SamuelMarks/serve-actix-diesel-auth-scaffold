#[derive(clap::Parser)]
#[command(version, about, long_about = None)]
struct Cli {
    /// Hostname
    #[arg(long, default_value = "localhost")]
    hostname: String,

    /// Port
    #[arg(short, long, default_value_t = 8080u16)]
    port: u16,

    /// Avoid inheriting host environment variables
    #[arg(long, default_value_t = false)]
    no_host_env: bool,

    /// Env file, defaults to ".env"
    #[arg(long)]
    env_file: Option<String>,

    /// Env var (can be specified multiple times, like `-eFOO=5 -eBAR=can`)
    #[arg(short, long, action(clap::ArgAction::Append))]
    env: Option<Vec<String>>,
}

#[derive(serde::Serialize)]
struct Version {
    version: String,
    name: String,
}

impl Default for Version {
    fn default() -> Self {
        Self {
            version: String::from(env!("CARGO_PKG_VERSION")),
            name: String::from(env!("CARGO_PKG_NAME")),
        }
    }
}

#[actix_web::get("/")]
async fn version() -> actix_web::web::Json<Version> {
    actix_web::web::Json(Version {
        version: String::from(env!("CARGO_PKG_VERSION")),
        name: String::from(env!("CARGO_PKG_NAME")),
    })
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let args: Cli = clap::Parser::parse();

    std::env::set_var("RUST_LOG", "debug");
    env_logger::init();
    let mut env = indexmap::IndexMap::<String, String>::new();
    if !args.no_host_env {
        env.extend(std::env::vars());
    }
    let env_file = args.env_file.unwrap_or(String::from(".env"));
    if let Ok(file_iter) = dotenvy::from_filename_iter(env_file) {
        for res in file_iter {
            if let Ok((k, v)) = res {
                env.insert(k, v);
            }
        }
    }
    if let Some(env_vec) = args.env {
        env.extend(env_vec.iter().filter_map(|s| match s.split_once("=") {
            None => None,
            Some((k, v)) => Some((k.to_string(), v.to_string())),
        }));
    };
    env.iter().for_each(|(k, v)| std::env::set_var(k, v));
    let database_url = std::env::var("DATABASE_URL").expect("DATABASE_URL must be set");

    let manager = diesel::r2d2::ConnectionManager::<diesel::PgConnection>::new(database_url);
    let pool = diesel::r2d2::Pool::builder().build(manager).unwrap();

    actix_web::HttpServer::new(move || {
        actix_web::App::new()
            .app_data(actix_web::web::Data::new(pool.clone()))
            .service(rust_actix_diesel_auth_scaffold::routes::token::token)
            .service(rust_actix_diesel_auth_scaffold::routes::authorisation::authorise)
            .service(version)
    })
    .bind((args.hostname.as_str(), args.port))?
    .run()
    .await
}
