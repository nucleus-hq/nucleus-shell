use helium::prelude::*;
use helium::compositors::{self, Workspace};
use helium::services::time;
use helium::slint_interpreter;
use helium::slint;

use helium::Helium as helium_wsr; // stands for struct. well wayland struct more specificly?

pub fn run(config: crate::config::Config) -> anyhow::Result<()> {
    log::info!("Starting bar");

    let density = config.bar.density;
    let default_height = config.bar.modules.default_height;
    let indicators = config.bar.modules.workspaces.indicators;
    let time_format = config.bar.modules.clock.format;

    let anchor = if config.bar.position == "bottom" {
        (AnchorEdge::Bottom, AnchorEdge::Left, AnchorEdge::Right)
    } else {
        (AnchorEdge::Top, AnchorEdge::Left, AnchorEdge::Right)
    };

    let wm = compositors::detect()?;
    let initial_workspaces = wm.workspaces();

    log::info!("workspaces: {:?}", initial_workspaces);

    let mut shell = helium_wsr::from_file("src/shell/modules/bar/bar.slint")
        .surface("Bar")
            .height(density)
            .anchor(anchor)
            .exclusive()
            .namespace("nucleus:bar")
        .build()?;

    shell.on_ready(move |rt| {
        rt.set("Bar", "workspaces", value_from_workspaces(&initial_workspaces, indicators.into()));
        rt.set("Bar", "workspace-count", indicators as f64);
        rt.set("Bar", "module-height", default_height as f64);
    });

    shell.on_compositor_event(wm, move |comp, ctx| {
        let clock = time::formatted(if time_format == "12h" { "%I:%M %p" } else { "%H:%M" });
        ctx.set("Bar", "clock-text", clock);

        match comp {
            compositors::CompositorEvent::WorkspacesUpdated(workspaces) => {
                ctx.set("Bar", "workspaces", value_from_workspaces(&workspaces, indicators.into()));
            }
            compositors::CompositorEvent::WorkspaceChanged(workspace) => {
                // If the compositor only emits a single workspace update, wrap it in a slice
                let workspaces = vec![workspace];
                ctx.set("Bar", "workspaces", value_from_workspaces(&workspaces, indicators.into()));
            }
            _ => {} // Ignore window focus, closure changes, or monitor adjustments
        }
    })?;

    shell.run()?;
    Ok(())
}

fn value_from_workspaces(workspaces: &[Workspace], count: u32) -> slint_interpreter::Value {
    // build a slot for each indicator index, find matching workspace if it exists
    let items: Vec<slint_interpreter::Value> = (1..=count)
        .map(|i| {
            let ws = workspaces.iter().find(|w| w.id == i);
            let mut s = slint_interpreter::Struct::default();
            s.set_field("active".into(), slint_interpreter::Value::Bool(
                ws.map(|w| w.active).unwrap_or(false)
            ));
            s.set_field("occupied".into(), slint_interpreter::Value::Bool(
                ws.map(|w| w.occupied).unwrap_or(false)
            ));
            slint_interpreter::Value::Struct(s)
        })
        .collect();
    let model = slint::VecModel::from(items);
    let model_rc: slint::ModelRc<slint_interpreter::Value> = std::rc::Rc::new(model).into();
    model_rc.into()
}