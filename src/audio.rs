use directories::UserDirs;
use kira::manager::AudioManager;
use kira::sound::SoundData;
use kira::{
    sound::static_sound::{StaticSoundData, StaticSoundSettings},
    tween::Tween,
};
use std::path::PathBuf;
use std::time::Duration;

pub struct CurrentTrack {
    pub index: Option<usize>,
    pub is_playing: bool,
    pub volume: f64,
    pub duration: Duration,
    pub handle: Option<<StaticSoundData as SoundData>::Handle>,
}

impl Default for CurrentTrack {
    fn default() -> Self {
        CurrentTrack {
            index: None,
            is_playing: false,
            volume: 0.5,
            duration: Duration::from_secs(0),
            handle: None,
        }
    }
}

impl CurrentTrack {
    pub fn play(&mut self, audio_manager: &mut AudioManager, music_list: &[PathBuf], index: usize) {
        if self.is_playing {
            let Some(ref mut handle) = self.handle else {
                return;
            };
            handle.stop(Tween::default()).unwrap();
            self.is_playing = false;
        }

        let sound_data = StaticSoundData::from_file(
            &music_list[index],
            StaticSoundSettings::new().volume(self.volume),
        )
        .unwrap();

        self.handle = audio_manager.play(sound_data.clone()).ok();
        self.is_playing = true;
        self.index = Some(index);
        self.duration = sound_data.duration();
    }

    pub fn toggle(&mut self) {
        let Some(ref mut handle) = self.handle else {
            return;
        };
        if self.is_playing {
            handle.pause(Tween::default()).unwrap();
            self.is_playing = false;
        } else {
            handle.resume(Tween::default()).unwrap();
            self.is_playing = true;
        }
    }

    pub fn set_volume(&mut self, volume: f64) {
        let Some(ref mut handle) = self.handle else {
            return;
        };
        handle.set_volume(volume, Tween::default()).unwrap();
        self.volume = volume;
    }

    pub fn seek(&mut self, current_position: &mut f64, position: f64) {
        let Some(ref mut handle) = self.handle else {
            return;
        };
        let Ok(_) = handle.seek_to(position) else {
            return;
        };
        *current_position = position;
    }
}

pub fn get_music_list() -> Vec<PathBuf> {
    let user_dirs = UserDirs::new().unwrap();
    let music_dir = user_dirs.audio_dir().unwrap();
    let Ok(entries) = music_dir.read_dir() else {
        return Vec::new();
    };

    entries
        .filter_map(|entry| {
            let Ok(entry) = entry else { return None };
            let path = entry.path();
            let Some(ext) = path.extension() else {
                return None;
            };

            if ext == "mp3" || ext == "ogg" {
                Some(path)
            } else {
                None
            }
        })
        .collect()
}
