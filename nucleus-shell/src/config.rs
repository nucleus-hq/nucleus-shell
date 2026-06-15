use helium::helium_config;

helium_config! {
    Config {
        bar: {
            density: u32 = 42,
            position: String = "top".to_string(), 
            modules: {
                default_height: u32 = 36,
                clock: {
                    format: String = "%H:%M".to_string(), 
                    interval_ms: u64 = 1000,
                },
                workspaces: {
                    indicators: u8 = 9,
                },
            },
        },
    }
}