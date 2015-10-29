# Keyczar-ios
An iOS-compatible version of Google's Keyczar library

## Acknowledgements
Thanks to the [Mitro team](https://github.com/mitro-co/mitro) for their awesome [patches and build scripts for keyczar](https://github.com/mitro-co/mitro/tree/master/mitro-core/cpp/third_party). This respository is based on their work.

## Instructions

* I'm lazy:
  Download the [compiled framework](/lazy/keyczar.framework.zip)

* I want to compile from source:
  Run ```./build-libs.sh```. The source files will be downloaded and patched automatically. Check the log files for errors under ```/build/logs```
  A framework file will be created under ```./build/framework```.

## Usage
Once the framework is built, add it to your Xcode project along with [zlib](https://gist.github.com/dulaccc/75f1f49f53e544cef549)

1. Make sure your target links with the frameworks;

![Link with frameworks](/instructions/link_binaries.png)

2. Keyczar is a C++ library, and so any class that interacts with it must be written in Objective-C++. To do this, rename your .m file to .mm:

![Setting file as c++](/instructions/mm_file.png)

3. Import Keyczar's header file and use:
```
#import <keyczar/keyczar.h>
```
```objective-c
- (void) doSomething {

NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"aes"];
keyczar::Keyczar* crypter = keyczar::Crypter::Read([path UTF8String]);
if (!crypter)
return;

std::string input = "Secret message";
std::string ciphertext;
cout << "Plaintext: " << input << endl;

bool result = crypter->Encrypt(input, &ciphertext);
if (result) {
std::cout << "Ciphertext (Base64w): " << ciphertext << std::endl;
std::string decrypted_input;
bool result = crypter->Decrypt(ciphertext, &decrypted_input);
if (result)
assert(input == decrypted_input);
std::cout << "Deciphered: " << decrypted_input;
}
delete crypter;

}
```
