use std::path::PathBuf;
use layer_shika::prelude::*;

pub fn run(_config: crate::config::Config) -> anyhow::Result<()> {
    log::info!("Starting bar");
    let cfg = _config;

    let ui_path = PathBuf::from(env!("CARGO_MANIFEST_DIR")).join("src/shell/modules/bar/bar.slint");

    let (height, position) = {
        (cfg.bar.height, cfg.bar.position)
    };

    Shell::from_file(ui_path)
        .surface("Bar")
        .height(height)
        .anchor(if position == "top" {
            AnchorEdges::top_bar()
        } else if position == "bottom" {
            AnchorEdges::bottom_bar()
        } else {
            AnchorEdges::top_bar()
        })        
        .exclusive_zone(height.try_into().unwrap()) // change u32 to i32
        .namespace("nucleus:bar")
        .build()?
        .run()?;

    Ok(())
}