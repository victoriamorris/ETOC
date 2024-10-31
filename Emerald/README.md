# Emerald <a id="Emerald"/>
Scripts for processing journal article metadata from Emerald, to convert to ETOC format.

[[back to top]](#Emerald)

## Requirements

Requires the ability to unzip files and run XSLT from the command line. 
Files needed to do this on Windows are included in the [Scripts](https://github.com/victoriamorris/ETOC/tree/main/Emerald/Scripts) folder.

Java must be installed in order to run the XSLT processor.

The command-line utility _sed_ must be available. This is included in the [Scripts](https://github.com/victoriamorris/ETOC/tree/main/Emerald/Scripts) folder in case it is needed.

[[back to top]](#Emerald)

## Running

Copy the entire folder structure to your local machine:
- **Input** folder
- **Output** folder
- **Scripts** folder, containing:
  - 7z.exe
  - 7z.dll
  - saxon.jar
  - nlm2etoc_v0-1.xsl
- **Emerald_ETOC.bat**

![Set up folder structure](https://github.com/victoriamorris/ETOC/blob/main/img/setup_files.png)

7z.exe and 7z.dll are used to unpack .zip archives.
saxon.jar is an XSLT processor.

Place input files into the Input folder.

![Place input files into the Input folder](https://github.com/victoriamorris/ETOC/blob/main/img/input_folder.png)

Run **Emerald_ETOC.bat**. 

The batch file will:
1. Unpack .zip archives and extract XML files to the top level of the Input folder
2. Delete <!DOCTYPE> declarations from each XML file.

```xslt
<!DOCTYPE article PUBLIC "-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD with MathML3 v1.1d1 20130915//EN" "JATS-archivearticle1-mathml3.dtd">
```

   An XSLT processor will be unable to process the XML files while the <!DOCTYPE> declaration is present 
   unless the relevant .dtd files are also accessible; 
   it is easier to delete the <!DOCTYPE> declaration than store the .dtd files.

   If required, the .dtd files can be downloaded from 
   https://jats.nlm.nih.gov/publishing/1.1/JATS-journalpublishing1-mathml3.dtd. 
   See https://jats.nlm.nih.gov/publishing/1.1/dtd.html for more information.

3. Apply the XSLT ```nlm2etoc_v0-1.xsl``` to each XML file, producing a text (.txt) file in the Output folder.
4. Concatenate all output files to a single text file in the top-level folder, with a filename of the form ```Emerald_ETOC_<dd>-<mm>-<yyyy>.txt```.

The file [Emerald/Emerald_ETOC_31-10-2024.txt](https://github.com/victoriamorris/ETOC/blob/265ced67c021a5fd8fae3a793b930cf3aad3483a/Emerald/Emerald_ETOC_31-10-2024.txt) shows example output.

[[back to top]](#Emerald)

## Mapping

The table below lists the ETOC fields included in the output, and uses XPath to indicate where the data is pulled from in the input files.

| ETOC field | Definition | Data source |
| ---------- | ---------- | ----------- |
| \<ID> | Unique identifier | Dummy value ER followed by a 9-digit running number |
| \<ITEM UIN> | Unique identifier | Dummy value Z000000000 |
| \<SHM> | Shelfmark | Print ISSN is found at ```article/front/journal-meta/[@publication-format='print']```<br/>A look-up table that is hard-coded into the XSLT finds the relevant shelfmark.<br/>If the ISSN is not present in the lookup table, a dummy shelfmark of 0000.000000 is given. 
| \<ISSUE> | Issue number, in the form YEAR; VOLUME; NUMBER | Year: ```article/front/article-meta/pub-date[@publication-format='print']/year```<br/>Volume: ```article/front/article-meta/volume```<br/>Number: ```article/front/article-meta/issue``` |
| \<AUTHOR> | Names of all authors, in the format _Surname, Forename_, separated by ; | ```article/article-meta/contrib-group/contrib//name``` |
| \<TITLE> | Article title | ```article/front/article-meta/title-group/article-title``` |
| \<PAGE> | Page range | ```article/front/article-meta/fpage``` and <br/> ```article/front/article-meta/lpage``` |
| \<LANG> | Language of article | Always 'E' for English, as the input metadata does not seem to include langauge information |

[[back to top]](#Emerald)

## Making changes

The filename of the XSLT is hard-coded into the batch file.
If the XSLT is amended and the version number in the file name is incremented, the batch file must also be amended.

[[back to top]](#Emerald)
