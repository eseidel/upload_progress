#[macro_use]
extern crate rocket;

use rocket::data::{Data, ToByteUnit};
use rocket::{post, routes, tokio::fs::File};
use std::io;

#[post("/upload", data = "<data>")]
async fn upload(data: Data<'_>) -> io::Result<String> {
    let mut file = File::create("foo.txt").await?;
    data.open(100.megabytes()).stream_to(&mut file).await?;
    Ok("Upload successful".into())
}

#[launch]
fn rocket() -> _ {
    rocket::build().mount("/", routes![upload])
}
