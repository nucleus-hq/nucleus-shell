fn main() {
    slint_build::compile_with_config(
        "src/shell/modules/bar/bar.slint",
        slint_build::CompilerConfiguration::new()
            .with_library_paths(std::collections::HashMap::from([(
                "material".into(),
                std::path::PathBuf::from("material"),
            )])),
    )
    .unwrap();
}