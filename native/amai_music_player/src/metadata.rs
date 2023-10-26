use lofty::{read_from_path, Accessor, Tag, TaggedFileExt};

// A 1x1 transparent image
#[rustfmt::skip]
pub const EMPTY_IMAGE: [u8; 68] = [
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x04, 0x00, 0x00, 0x00, 0xb5, 0x1c, 0x0c, 
    0x02, 0x00, 0x00, 0x00, 0x0b, 0x49, 0x44, 0x41, 0x54, 0x78, 0xda, 0x63, 0x64, 0x60, 0x00, 0x00, 
    0x00, 0x06, 0x00, 0x02, 0x30, 0x81, 0xd0, 0x2f, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 
    0xae, 0x42, 0x60, 0x82
];

pub struct Track {
    pub path: String,
}

impl Track {
    fn primary_tag(&self) -> Option<Tag> {
        if self.path.is_empty() {
            None
        } else {
            let audio_file = read_from_path(&self.path).expect("Could not get audio file");

            audio_file.primary_tag().cloned()
        }
    }

    pub fn art(&self) -> Vec<u8> {
        match self.primary_tag() {
            Some(tag) => tag.pictures()[0].data().to_vec(),
            None => EMPTY_IMAGE.to_vec(),
        }
    }

    pub fn title(&self) -> String {
        match self.primary_tag() {
            Some(tag) => {
                let Some(title) = tag.title() else {
                    return String::new();
                };

                title.to_string()
            }
            _ => String::new(),
        }
    }
}
