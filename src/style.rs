use iced::gradient::Linear;
use iced::theme::Button;
use iced::widget::button;
use iced::{Color, Gradient, Radians};

pub enum MusicListButton {
    Primary,
    Selected,
}

impl button::StyleSheet for MusicListButton {
    type Style = iced::Theme;

    fn active(&self, style: &Self::Style) -> button::Appearance {
        let appearance = button::Appearance {
            // background: Some(iced::Color::from_rgb(0.251, 0.941, 0.651).into()),
            background: Some(iced::Background::Gradient(Gradient::Linear(
                Linear::new(Radians(0.5))
                    .add_stop(0., Color::from_rgb(0.251, 0.941, 0.651))
                    .add_stop(1.0, Color::from_rgb(0.0, 0.0, 1.0)),
            ))),
            border_radius: 5.0.into(),
            ..Default::default()
        };

        match self {
            MusicListButton::Primary => appearance,
            MusicListButton::Selected => self.pressed(style),
        }
    }

    fn hovered(&self, style: &Self::Style) -> button::Appearance {
        // Define the button style when hovered (elevated)
        button::Appearance {
            background: Some(iced::Color::from_rgb(0.3, 0.99, 0.7).into()),
            border_width: 1.0,
            border_color: iced::Color::from_rgb(0.1, 0.8, 0.5),
            shadow_offset: iced::Vector::new(5.0, 10.0),
            ..self.active(style)
        }
    }

    fn pressed(&self, style: &Self::Style) -> button::Appearance {
        button::Appearance {
            shadow_offset: iced::Vector::default(),
            ..self.active(style)
        }
    }

    fn disabled(&self, style: &Self::Style) -> button::Appearance {
        let active = self.active(style);

        button::Appearance {
            shadow_offset: iced::Vector::default(),
            background: active.background.map(|background| match background {
                iced::Background::Color(color) => iced::Background::Color(iced::Color {
                    a: color.a * 0.5,
                    ..color
                }),
                iced::Background::Gradient(gradient) => {
                    iced::Background::Gradient(gradient.mul_alpha(0.5))
                }
            }),
            text_color: iced::Color {
                a: active.text_color.a * 0.5,
                ..active.text_color
            },
            ..active
        }
    }
}

impl From<MusicListButton> for Button {
    fn from(ml_button: MusicListButton) -> Self {
        Button::custom(ml_button)
    }
}
