use directories::UserDirs;

pub fn get_music_files() -> (Vec<String>, String) {
    let user_dirs = UserDirs::new().expect("Could not find user dir");
    let music_dir = user_dirs.audio_dir().expect("Could not find audio dir");
    let entries = music_dir.read_dir().expect("Could not read audio dir");

    (
        entries
            .filter(|entry| {
                let Ok(entry) = entry else { return false };
                let path = entry.path();
                let Some(ext) = path.extension() else {
                    return false;
                };
                ext == "mp4" || ext == "ogg"
            })
            .map(|entry| {
                entry
                    .expect("Could not unwrap entry file")
                    .path()
                    .into_os_string()
                    .into_string()
                    .expect("Could not turn os string into string")
            })
            .collect(),
        music_dir.to_str().unwrap().to_string(),
    )
}
