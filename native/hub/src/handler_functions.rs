use crate::bridge::api::{RustOperation, RustRequest, RustResponse};
use amai_music_player::files::get_music_files;
use amai_music_player::metadata::Track;
use prost::Message;

pub async fn handle_get_music_files(rust_request: RustRequest) -> RustResponse {
    use crate::messages::get_music_files::CreateResponse;

    match rust_request.operation {
        RustOperation::Create => {
            let (music_files, music_folder) = get_music_files();

            let response_message = CreateResponse {
                music_files,
                music_folder,
            };

            RustResponse {
                successful: true,
                message: Some(response_message.encode_to_vec()),
                blob: None,
            }
        }
        _ => RustResponse::default(),
    }
}

pub async fn handle_get_metadata(rust_request: RustRequest) -> RustResponse {
    use crate::messages::get_metadata::{ReadRequest, ReadResponse};

    match rust_request.operation {
        RustOperation::Read => {
            let message_bytes = rust_request.message.unwrap();
            let request_message = ReadRequest::decode(message_bytes.as_slice()).unwrap();

            let track = Track {
                path: request_message.path,
            };

            let art = track.art();
            let title = track.title();

            let response_message = ReadResponse { art, title };

            RustResponse {
                successful: true,
                message: None,
                blob: Some(response_message.encode_to_vec()),
            }
        }
        _ => RustResponse::default(),
    }
}
