# MyLISP for Sinclair QL

MyLISP is a LISP-1 interpreter designed specifically to run on Sinclair QL computers and compatible emulators (requires 640KB RAM minimum). 

This repository contains the executable binaries for the interpreter, reference manuals, example programs, and the necessary files to translate the interface into other languages.

## 📂 Repository Structure

The repository is organized into the following directories:

* `/EN`: Contains the MyLISP executable and the reference manual in English.
* `/ES`: Contains the MyLISP executable and the reference manual in Spanish.
* `/examples`: A collection of LISP programs to run on the interpreter.
* `/lang-templates`: Contains the base text files (`msg_EN.pas` and `msg_ES.pas`) required for localization.

## 💡 Included Examples

Inside the `/examples` folder, you will find the following scripts to test the capabilities of the MyLISP interpreter:

* **`BASIC`**: A comprehensive test suite demonstrating the environment's fundamentals. It covers data types, list manipulation, flow control, classical recursive functions (like Fibonacci and Factorial), and controlled error handling to show the REPL's resilience.
* **`SORT`**: An implementation of the Selection Sort algorithm using recursive list processing and custom minimum-value extraction functions.
* **`DERIVA`**: A classic Lisp demonstration of symbolic computation. It acts as a symbolic differentiator, parsing mathematical expressions as trees and applying derivation rules alongside basic algebraic simplifications.
* **`ORDEN`**: A demonstration of functional programming concepts. It defines the higher-order paradigms `MAP`, `FILTER`, and `REDUCE` from scratch, applying them to custom predicates and arithmetic operations.

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

* MyLISP binaries and documentation are Freeware. You may use them for any purpose, including commercial projects. However, the resale, repackaging, or direct monetization of the MyLISP software itself is strictly prohibited.
* The scripts and programs inside the `/examples` folder are in the public domain; you may use and modify them as you see fit.
