use std::path::PathBuf;
use std::rc::Rc;
use std::time::Duration;
use layer_shika::prelude::*;
use layer_shika::slint_interpreter::{Value, Struct};
use layer_shika_adapters::platform::calloop::TimeoutAction;
use slint::{ModelRc, VecModel};

use crate::shell::services::hyprland;

fn make_ws_values(workspaces: &[hyprland::Workspace]) -> Value {
    let values: Vec<Value> = workspaces.iter().map(|w| {
        let mut s = Struct::default();
        s.set_field("active".into(), Value::Bool(w.active));
        s.set_field("occupied".into(), Value::Bool(w.occupied));
        Value::Struct(s)
    }).collect();
    Value::Model(ModelRc::from(Rc::new(VecModel::from(values))))
}

pub fn run(config: crate::config::Config) -> anyhow::Result<()> {
    log::info!("Starting bar");

    let ui_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"))
        .join("src/shell/modules/bar/bar.slint");

    let mut shell = Shell::from_file(ui_path)
        .surface("Bar")
        .height(config.bar.density)
        .anchor(if config.bar.position == "top" {
            AnchorEdges::top_bar()
        } else if config.bar.position == "bottom" {
            AnchorEdges::bottom_bar()
        } else {
            AnchorEdges::top_bar()
        })
        .exclusive_zone(config.bar.density as i32)
        .namespace("nucleus:bar")
        .build()?;

    // set initial data
    let workspaces = hyprland::get_workspaces(config.bar.modules.workspaces.indicators as i32);
    shell.with_component("Bar", |comp| {
        comp.set_property("workspaces", make_ws_values(&workspaces)).unwrap();
        comp.set_property("workspace-count", Value::Number(config.bar.modules.workspaces.indicators as f64)).unwrap();
        comp.set_property("module-height", Value::Number(config.bar.modules.default_height.into())).unwrap();
    });

    let indicators = config.bar.modules.workspaces.indicators;
    let time_format = config.bar.modules.clock.time_format.clone();

    shell.event_loop_handle().add_timer(
        Duration::from_millis(100),
        move |_deadline, app_state| {
            let workspaces = hyprland::get_workspaces(indicators as i32);
            let ws_value = make_ws_values(&workspaces);
            let clock = if time_format == "12h" {
                chrono::Local::now().format("%I:%M %p").to_string()
            } else {
                chrono::Local::now().format("%H:%M").to_string()
            };
            for surface in app_state.surfaces_by_name("Bar") {
                let comp = surface.component_instance();
                comp.set_property("workspaces", ws_value.clone()).unwrap();
                comp.set_property("clock-text", Value::String(clock.clone().into())).unwrap();
            }
            TimeoutAction::ToDuration(Duration::from_millis(100))
        }
    )?;

    shell.run()?;
    Ok(())
}