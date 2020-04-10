use std::io;
use std::fs;
use std::ffi::CStr;
use std::os::raw::c_char;

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
        }
        Err(_) => {
          // handle the error
        }
    }    
    
    return 0;
}