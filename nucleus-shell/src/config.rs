use serde::{Deserialize, Serialize};
use std::fs;

#[derive(Debug, Serialize, Deserialize)]
pub struct Config {
    pub bar: BarConfig,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct BarConfig {
    pub density: u32,
    pub position: String,
    pub modules: BarModuleConfig,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct BarModuleConfig {
    pub default_height: u32,
    pub workspaces: WorkspacesConfig,
    pub clock: ClockConfig,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct WorkspacesConfig {
    pub indicators: u32,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ClockConfig {
    pub time_format: String, // "24h" or "12h"
}

impl Default for Config {
    fn default() -> Self {
        Config {
            bar: BarConfig {
                density: 42,
                position: "top".to_string(),
                modules: BarModuleConfig {
                    default_height: 36,
                    workspaces: WorkspacesConfig {
                        indicators: 8,
                    },
                    clock: ClockConfig {
                        time_format: "24h".to_string(),
                    },
                },
            },
        }
    }
}

impl Config {
    pub fn load() -> Self {
        let path = dirs::state_dir()
            .unwrap()
            .join("nucleus-shell/config.json");

        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).expect("failed to create config directories");
        }

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