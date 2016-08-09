extern crate hyper;
extern crate url;

use hyper::Client;
use hyper::client::RedirectPolicy;
use hyper::header::{Headers, ContentType};
use hyper::mime::{Mime, TopLevel, SubLevel};
use hyper::client::response::Response;
use std::io::Error;
use std::io::Read;
use std::string::String;
use url::form_urlencoded;

fn main() {
    println!("Hello, world!");

    let mut client = Client::new();
    client.set_redirect_policy(RedirectPolicy::FollowNone);

    let mut headers = Headers::new();
    headers.set(
        ContentType(
            Mime(TopLevel::Application,
                SubLevel::WwwFormUrlEncoded,
                vec![]
            )
        )
    );

    let mut serializer = form_urlencoded::Serializer::new(String::new());
    serializer.append_pair("mail", "");
    serializer.append_pair("password", "");
    let encoded : String = serializer.finish();

    println!("{:?}", encoded);

    let mut res = client
        .post("https://secure.nicovideo.jp/secure/login")
        .body(&*encoded)
        .headers(headers)
        .send()
        .unwrap();

    let body = read_response(&mut res);

    println!("{:?}", res);
    println!("{:?}", body);
}

fn read_response(response: &mut Response) -> Result<i32, Error> {
    let mut vec = Vec::new();
    let size = response.read_to_end(&mut vec);
    return size.map(|i| {
        println!("read size: {:?}", i);

        let string = match String::from_utf8(vec) {
            Ok(v) => v,
            Err(e) => panic!("Not utf8 {}", e),
        };

        print!("{:?}", string);

        999
    });
}
