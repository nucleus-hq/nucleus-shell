use std::io::{Read, Write};
use std::os::unix::net::UnixStream;

#[derive(Clone, Debug)]
pub struct Workspace {
    pub id: i32,
    pub occupied: bool,
    pub active: bool,
}

fn socket_path(event: bool) -> String {
    let runtime = std::env::var("XDG_RUNTIME_DIR").unwrap();
    let sig = std::env::var("HYPRLAND_INSTANCE_SIGNATURE").unwrap();
    let sock = if event { ".socket2.sock" } else { ".socket.sock" };
    format!("{}/hypr/{}/{}", runtime, sig, sock)
}

pub fn command(cmd: &str) -> String {
    let mut stream = UnixStream::connect(socket_path(false)).unwrap();
    stream.write_all(cmd.as_bytes()).unwrap();
    let mut response = String::new();
    stream.read_to_string(&mut response).unwrap();
    response
}

pub fn get_workspaces(num: i32) -> Vec<Workspace> {
    let active_json = command("j/activeworkspace");
    let active_id: i32 = serde_json::from_str::<serde_json::Value>(&active_json)
        .unwrap()["id"]
        .as_i64()
        .unwrap_or(1) as i32;

    let occupied_json = command("j/workspaces");
    let occupied: Vec<i32> = serde_json::from_str::<Vec<serde_json::Value>>(&occupied_json)
        .unwrap_or_default()
        .iter()
        .filter_map(|w| w["id"].as_i64().map(|id| id as i32))
        .collect();

    (1..=num).map(|id| Workspace {
        id,
        active: id == active_id,
        occupied: occupied.contains(&id),
    }).collect()
}

pub fn event_listener(on_event: impl Fn(String) + Send + 'static) {
    std::thread::spawn(move || {
        let mut stream = UnixStream::connect(socket_path(true)).unwrap();
        let mut buf = [0u8; 4096];
        loop {
            match stream.read(&mut buf) {
                Ok(n) if n > 0 => {
                    let data = String::from_utf8_lossy(&buf[..n]).to_string();
                    for line in data.lines() {
                        on_event(line.to_string());
                    }
                }
                _ => break,
            }
        }
    });
}