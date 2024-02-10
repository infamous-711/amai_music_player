use anyhow::{Context, Result};
use directories::UserDirs;

pub struct Track {
    pub name: String,
    pub path: String, // TODO: replace with PathBuf
    pub id: Option<usize>,
}

pub fn get_music_files() -> Result<Vec<Track>> {
    let user_dirs = UserDirs::new().context("Could not get user directory!")?;
    let music_dir = user_dirs
        .audio_dir()
        .context("Audio directory not found!")?;
    let entries = music_dir.read_dir()?;

    Ok(entries
        .into_iter()
        .enumerate()
        .filter_map(|(id, entry)| {
            let entry = entry.ok()?;
            let path = entry.path();
            let ext = path.extension()?.to_string_lossy().to_string();
            // TODO: add support for other types
            if ext == "mp3" || ext == "ogg" {
                Some(
                    Track {
                        name: path.file_stem()?.to_str()?.to_string(),
                        path: path.to_str()?.to_string(),
                        id: Some(id), // TODO: find a better solution for track id
                    }
                )
            } else {
                None
            }
        })
        .collect())
}
