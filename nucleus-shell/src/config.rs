use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Debug, Serialize, Deserialize)]
pub struct Config {
    pub bar: BarConfig,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct BarConfig {
    pub height: u32,
    pub position: String,
}

impl Default for Config {
    fn default() -> Self {
        Config {
            bar: BarConfig {
                height: 42,
                position: "top".to_string(),
            },
        }
    }
}

impl Config {
    pub fn load() -> Self {
        let path = dirs::state_dir()
            .unwrap()
            .join("nucleus-shell/config.json");

        // create parent folders if they don't exist
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("failed to create config directories");
        }

        // file doesn't exist or is empty — write defaults
        if !path.exists() || fs::metadata(&path).map(|m| m.len() == 0).unwrap_or(true) {
            let default = Config::default();
            let json = serde_json::to_string_pretty(&default).expect("failed to serialize config");
            fs::write(&path, json).expect("failed to write default config");
            return default;
        }

        let content = fs::read_to_string(&path).expect("failed to read config");
        serde_json::from_str(&content).expect("invalid config.json")
    }
}