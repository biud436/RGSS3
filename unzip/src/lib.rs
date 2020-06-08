use std::io;
use std::fs;
use std::ffi::CStr;
use std::os::raw::c_char;

#[cfg(windows)] extern crate winapi;
use std::io::Error;

/**
 * @link https://github.com/retep998/winapi-rs
 */
#[cfg(windows)]
fn print_message(msg: &str) -> Result<i32, Error> {
    use std::ffi::OsStr;
    use std::iter::once;
    use std::os::windows::ffi::OsStrExt;
    use std::ptr::null_mut;
    use winapi::um::winuser::{MB_OK, MessageBoxW};
    let wide: Vec<u16> = OsStr::new(msg).encode_wide().chain(once(0)).collect();
    let ret = unsafe {
        MessageBoxW(null_mut(), wide.as_ptr(), wide.as_ptr(), MB_OK)
    };
    if ret == 0 { Err(Error::last_os_error()) }
    else { Ok(ret) }
}
#[cfg(not(windows))]
fn print_message(msg: &str) -> Result<(), Error> {
    println!("{}", msg);
    Ok(())
}

#[no_mangle]
pub extern "C" fn extractZip(ptr: *const c_char) -> i32 {
    let cstr = unsafe { CStr::from_ptr(ptr) };

    match cstr.to_str() {
        Ok(s) => {

            let fname = std::path::Path::new(&s);
            let file = fs::File::open(&fname).unwrap();
            let parent = fname.parent().unwrap();
            let dir = fname.file_stem().unwrap();

            let maybe_dir = parent.join(dir);
            if !maybe_dir.exists() {
                std::fs::create_dir_all(&maybe_dir).unwrap();
            }

            let mut archive = zip::ZipArchive::new(file).unwrap();

            for i in 0..archive.len() {
                let mut file = archive.by_index(i).unwrap();
                let mut outpath = std::path::PathBuf::new();
                
                outpath.push(maybe_dir.to_str().unwrap());
                outpath.push(file.sanitized_name());

                {
                    let comment = file.comment();
                    if comment.len() > 0 { println!("  File comment: {}", comment); }
                }                
        
                if (&*file.name()).ends_with('/') {
                    println!("파일 {} 의 압축을 \"{}\"에 풀었습니다.", i, outpath.as_path().display());
                    fs::create_dir_all(&outpath).unwrap();
                } else {
                    println!("파일 {} 의 압축을 \"{}\"에 풀었습니다. ({} bytes)", i, outpath.as_path().display(), file.size());
                    if let Some(p) = outpath.parent() {
                        if !p.exists() {
                            fs::create_dir_all(&p).unwrap();
                        }
                    }
                    let mut outfile = fs::File::create(&outpath).unwrap();
                    io::copy(&mut file, &mut outfile).unwrap();
                }
            }
        },
        Err(_e) => {
          print_message("압축 해제 도중에 오류가 발생하였습니다").unwrap();
        }
    }    
    
    return 0;
}