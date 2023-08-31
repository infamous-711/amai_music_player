use crate::{
    audio::{change_volume, get_music_list, play_track, toggle_play},
    style::MusicListButton,
};
use iced::{
    executor,
    widget::{button, column, container, row, scrollable, slider, text, Column},
    Application, Command, Element, Length, Settings, Theme,
};
use kira::{
    manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings},
    sound::{static_sound::StaticSoundData, SoundData},
};
use std::path::PathBuf;

mod audio;
mod style;

#[derive(Debug, Copy, Clone)]
pub enum Message {
    TogglePlay,
    PlayTrack(usize),
    ChangeVolume(f64),
}

pub struct AmaiPlayer {
    is_playing: bool,
    music_list: Vec<PathBuf>,
    current_track: Option<<StaticSoundData as SoundData>::Handle>,
    current_volume: f64,
    audio_manager: AudioManager,
    selected_track_index: Option<usize>,
}

impl Application for AmaiPlayer {
    type Message = Message;
    type Executor = executor::Default;
    type Flags = ();
    type Theme = Theme;

    fn new(_flags: Self::Flags) -> (Self, Command<Self::Message>) {
        let music_list = get_music_list();
        let audio_manager =
            AudioManager::<DefaultBackend>::new(AudioManagerSettings::default()).unwrap();

        (
            AmaiPlayer {
                music_list,
                audio_manager,
                current_track: None,
                current_volume: 0.5,
                is_playing: false,
                selected_track_index: None,
            },
            Command::none(),
        )
    }

    fn title(&self) -> String {
        "Amai Music Player".to_string()
    }

    fn theme(&self) -> Theme {
        Theme::Dark
    }

    fn update(&mut self, message: Self::Message) -> Command<Self::Message> {
        match message {
            Message::TogglePlay => toggle_play(self),
            Message::PlayTrack(index) => {
                self.selected_track_index = Some(index);
                play_track(self, index);
            }
            Message::ChangeVolume(volume) => change_volume(self, volume),
        };

        Command::none()
    }

    fn view(&self) -> iced::Element<'_, Self::Message> {
        let play_button =
            button(text(if self.is_playing { "⏸" } else { "▶" }).shaping(text::Shaping::Advanced))
                .on_press(Message::TogglePlay);

        let volume_slider =
            slider(0.0..=1.0f64, self.current_volume, Message::ChangeVolume).step(0.01);

        let music_buttons: Element<_> = self
            .music_list
            .iter()
            .enumerate()
            .fold(
                Column::new().spacing(2).width(Length::Fill),
                |column, (index, file)| {
                    let file_name = file.file_stem().unwrap().to_str().unwrap();
                    let button_text =
                        text(file_name).shaping(match contains_non_english_chars(file_name) {
                            true => text::Shaping::Advanced,
                            false => text::Shaping::Basic,
                        });

                    let is_selected = self.selected_track_index == Some(index);

                    let music_button = button(button_text)
                        .padding(10)
                        .width(Length::Fill)
                        .style(if is_selected {
                            MusicListButton::Selected.into()
                        } else {
                            MusicListButton::Primary.into()
                        })
                        .on_press(Message::PlayTrack(index));

                    column.push(music_button)
                },
            )
            .into();

        let music_list = scrollable(music_buttons);

        let music_list_container = container(music_list)
            .width(Length::Fill)
            .height(Length::Fill);

        let final_content = column![
            music_list_container,
            row![play_button, volume_slider].spacing(20).padding(10)
        ];

        container(final_content)
            .width(Length::Fill)
            .height(Length::Fill)
            .into()
    }
}

fn contains_non_english_chars(input: &str) -> bool {
    for c in input.chars() {
        if !c.is_ascii_alphanumeric() {
            return true;
        }
    }

    false
}

fn main() -> iced::Result {
    AmaiPlayer::run(Settings::default())
}
