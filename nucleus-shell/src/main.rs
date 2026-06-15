mod shell;
mod config;

fn main() -> anyhow::Result<()> {
    env_logger::builder()
        .filter_level(log::LevelFilter::Info)
        .init();


    let config = config::Config::load("config.json")?;

    Ok(shell::modules::bar::run(config)?)
}