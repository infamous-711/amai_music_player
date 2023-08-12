use iced::widget::button;
use iced::theme::Button;

pub enum MusicListButton {
    Primary,
    Selected
}

impl button::StyleSheet for MusicListButton {
    type Style = iced::Theme;

    
    fn active(&self, _style: &Self::Style) -> button::Appearance {
        let appearance = button::Appearance {
            background: Some(iced::Color::from_rgb(0.251, 0.941, 0.651).into()),
            border_radius: 5.0.into(),
            ..Default::default()
        };

        match self {
            MusicListButton::Primary => appearance,
            MusicListButton::Selected => button::Appearance {
                background: Some(iced::Color::from_rgb(0.1, 0.8, 0.5).into()),
                ..appearance
            },
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
}


impl From<MusicListButton> for Button {
    fn from(ml_button: MusicListButton) -> Self {
        Button::custom(ml_button)
    }
}
