# MyLISP for Sinclair QL

MyLISP is a LISP-1 interpreter designed specifically to run on Sinclair QL computers and compatible emulators (with 640kb RAM). 

This repository contains the executable binaries for the interpreter, reference manuals, example programs, and the necessary files to translate the interface into other languages.

## 📂 Repository Structure

The repository is organized into the following directories:

* `/EN`: Contains the MyLISP executable and the reference manual in English.
* `/ES`: Contains the MyLISP executable and the reference manual in Spanish.
* `/examples`: A collection of LISP programs to run on the interpreter (e.g., algorithms, proofs of concept, and math scripts).
* `/lang-templates`: Contains the base text files (`msg_EN.pas` and `msg_ES.pas`) required for localization.

## 🚀 Usage and Distribution

MyLISP is **Freeware**. You can download, use, and freely distribute the binaries and manuals as long as they remain unmodified. 

**Note on source code:** This is a closed-source project. The source code for the interpreter engine is not published in this repository and is not available for download. 

## 🌍 Contribute: Translate MyLISP into another language

If you want MyLISP to be available in your native language, you can contribute by translating the system messages. Since the main source code is closed, the process is as follows:

1. Go to the `/lang-templates` folder and download one of the base files (for example, `msg_EN.pas`).
2. Edit the text strings inside the file with your translation. Please keep any variables and formatting characters intact.
3. Rename the file to indicate the target language (e.g., `msg_FR.pas` for French, `msg_IT.pas` for Italian).
4. Open an **Issue** in this repository and attach your file, or submit a **Pull Request** adding it to the `/lang-templates` folder.
5. Once reviewed, I will compile a new MyLISP binary with your translation, create a new language folder (e.g., `/FR`), and credit your work in this README.

## 📜 License

* MyLISP binaries and documentation are Freeware. Commercial use, resale, or monetization of any kind is strictly prohibited.
* The scripts and programs inside the `/examples` folder are in the public domain; you may use and modify them as you see fit.
