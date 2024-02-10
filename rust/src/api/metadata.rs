use anyhow::Result;
pub use lofty::{Accessor, Tag, TaggedFileExt};

pub struct Metadata {
    pub tag: Option<Tag>,
    pub art: Option<Vec<u8>>,
    pub title: Option<String>,
}

pub fn get_metadata(path: String) -> Result<Metadata> {
    let tags = lofty::read_from_path(path)?;
    let primary_tag = tags.primary_tag();

    let art = primary_tag.map(|tag| tag.pictures()[0].data().to_vec());
    let title = primary_tag.map(|tag| tag.title().unwrap().to_string());

    Ok(Metadata {
        tag: primary_tag.cloned(),
        art,
        title,
    })
}
