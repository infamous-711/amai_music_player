use crate::audio::{get_music_list, CurrentTrack};
use iced::{
    executor,
    widget::{button, column, container, row, scrollable, slider, text, text_input, Column},
    Application, Command, Element, Length, Settings, Subscription, Theme,
};
use kira::manager::{backend::DefaultBackend, AudioManager, AudioManagerSettings};
use std::path::PathBuf;
use std::time::Duration;

mod audio;

#[derive(Debug, Clone)]
pub enum Message {
    TogglePlay,
    PlayTrack(usize),
    ChangeVolume(f64),
    ChangePosition(f64),
    UpdatePosition,
    SearchMusic(String),
}

pub struct AmaiPlayer {
    music_list: Vec<PathBuf>,
    audio_manager: AudioManager,
    current_track: CurrentTrack,
    position: f64,
    search_query: String,
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
                current_track: CurrentTrack::default(),
                position: 0.,
                search_query: String::new(),
            },
            Command::none(),
        )
    }

    fn title(&self) -> String {
        "Amai Music Player".to_string()
    }

    fn theme(&self) -> Theme {
        // TODO: Add a custom theme/style
        Theme::Dark
    }

    fn update(&mut self, message: Self::Message) -> Command<Self::Message> {
        match message {
            Message::TogglePlay => self.current_track.toggle(),
            Message::PlayTrack(index) => {
                self.current_track
                    .play(&mut self.audio_manager, &self.music_list, index)
            }
            Message::ChangeVolume(volume) => self.current_track.set_volume(volume),
            Message::ChangePosition(position) => {
                self.current_track.seek(&mut self.position, position)
            }
            Message::UpdatePosition => match &self.current_track.handle {
                Some(handle) => self.position = handle.position(),
                None => self.position = 0.,
            },
            Message::SearchMusic(query) => self.search_query = query,
        };

        Command::none()
    }

    fn view(&self) -> iced::Element<'_, Self::Message> {
        let play_button = button(
            text(if self.current_track.is_playing {
                "||"
            } else {
                "|>"
            })
            .shaping(text::Shaping::Advanced),
        )
        .on_press(Message::TogglePlay);

        let volume_slider = slider(
            0.0..=1.0f64,
            self.current_track.volume,
            Message::ChangeVolume,
        )
        .step(0.01)
        .width(Length::Fill);

        let duration = self.current_track.duration.as_secs() as f64;

        let position_slider =
            slider(0.0..=duration, self.position, Message::ChangePosition).step(0.01).width(Length::FillPortion(4));

        let music_buttons: Element<_> = self
            .music_list
            .iter()
            .enumerate()
            .filter(|(_, name)| {
                name.to_str()
                    .unwrap()
                    .to_lowercase()
                    .as_str()
                    .contains(self.search_query.to_lowercase().as_str())
            })
            .fold(
                Column::new().spacing(2).width(Length::Fill),
                |column, (index, file)| {
                    let file_name = file.file_stem().unwrap().to_str().unwrap();
                    let button_text =
                        text(file_name).shaping(match contains_non_english_chars(file_name) {
                            true => text::Shaping::Advanced, // use Advanced shaping if there's a unicode character
                            false => text::Shaping::Basic, // use Basic shaping if there's only alphanumeric characters
                        });

                    let music_button = button(button_text)
                        .padding(10)
                        .width(Length::Fill)
                        .on_press(Message::PlayTrack(index));

                    column.push(music_button)
                },
            )
            .into();

        let music_list = scrollable(music_buttons);

        let music_list_container = container(music_list)
            .width(Length::Fill)
            .height(Length::Fill);

        let searchbar = text_input("Search Music", &self.search_query)
            .on_input(Message::SearchMusic)
            .padding(10);

        let final_content = column![
            searchbar,
            music_list_container,
            row![play_button, position_slider, volume_slider]
                .spacing(20)
                .padding(10),
        ];

        container(final_content)
            .width(Length::Fill)
            .height(Length::Fill)
            .into()
    }
    fn subscription(&self) -> Subscription<Self::Message> {
        if !self.current_track.is_playing {
            return Subscription::none();
        }

        iced::time::every(Duration::from_secs(2)).map(|_| Message::UpdatePosition)
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
