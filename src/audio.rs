use std::path::PathBuf;
use directories::UserDirs;
use kira::{
    sound::static_sound::{StaticSoundData, StaticSoundSettings},
    tween::Tween,
};
use crate::AmaiPlayer;

pub fn play_track(state: &mut AmaiPlayer, index: usize) {
    if state.is_playing {
        if let Some(ref mut current_track) = &mut state.current_track {
            current_track.stop(Tween::default()).unwrap();
            state.is_playing = false;
        }
    }

    let sound_data = StaticSoundData::from_file(
        &state.music_list[index],
        StaticSoundSettings::new().volume(state.current_volume),
    )
    .unwrap();

    state.current_track = state.audio_manager.play(sound_data).ok();
    state.is_playing = true;
}

pub fn toggle_play(state: &mut AmaiPlayer) {
    if let Some(ref mut current_track) = &mut state.current_track {
        if state.is_playing {
            current_track.pause(Tween::default()).unwrap();
            state.is_playing = false;
        } else {
            current_track.resume(Tween::default()).unwrap();
            state.is_playing = true;
        }
    }
}

pub fn change_volume(state: &mut AmaiPlayer, volume: f64) {
    if let Some(ref mut current_track) = &mut state.current_track {
        current_track
            .set_volume(volume, Tween::default())
            .unwrap();
    }
    state.current_volume = volume;
}

pub fn get_music_list() -> Vec<PathBuf> {
    let user_dirs = UserDirs::new().unwrap();
    let music_dir = user_dirs.audio_dir().unwrap();
    let Ok(entries) = music_dir.read_dir() else { return Vec::new() };

    entries
        .filter(|entry| {
            let Ok(entry) = entry else { return false };
            let path = entry.path();
            let Some(ext) = path.extension() else { return false };

            ext == "mp4" || ext == "ogg"
        })
        .map(|entry| entry.unwrap().path())
        .collect()
}
