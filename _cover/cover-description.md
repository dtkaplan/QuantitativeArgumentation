# Cover description

The book cover will be defined using latex/tikz and compiled to PDF. The source document will be new-cover.tex and the compiled product will be new-cover.pdf.

# Product

You are to produce the file "new-cover.tex" which will be a stand-alone latex file that I can compile to pdf using the command "latexmk -pdf -interaction=nonstopmode new-cover.tex"

- The source file for the cover will be in the _cover subdirectory of the project root
- The overall size will be 17.89" wide by 11.25" high.

## Document background picture

- The image _cover/JJ-tiles.png fill provide the full-page background for the entire cover.

## Front of the cover

- The front of the cover will contain the title and subtitle in a very large font.
    - Title: "Quantitative Argumentation" in bold font \fontsize{64}{72} spread over two lines. There should be 0.5" of blank vertical space between the bottom of the top line and the top of the bottom line. 
    - Subtitle: "Making Sense with Numbers" in italics in a \fontsize{50}{60}
    - the title and subtitle should be centered vertically and horizontally in the white overlay box. 
    - As background for the title and subtitle, place a translucent white box with rounded corners, around a point 13.51" from the left edge of the document and 7.25" from the bottom edge of the document, opacity about 0.75, with no border. The box will be 6.25" wide and 4.0" tall.

- Below the title/subtitle box, will be a similar white box, 6.25" wide but only 1.25" tall. It will contain the author's name: "Daniel T. Kaplan" in a non-italic font the same size as the font for the subtitle. This author white box should have the top placed 2.0" under the bottom of the title's white box. 

## Spine of the book

The spine of the book will be marked by a translucent white rectangle the full height of the cover, 0.637" wide, and located 8.625" from the left edge of the cover. 

- The spine will have sideways black text rotated 90 degrees clockwise, starting 0.75" from the top of the cover. The text will be in bold font of \fontsize{28}{30} to fit in the white box. The text reads "Quantitative Argumentation [1" blank space] Kaplan"
- Also in the spine, will be an image and text that will be oriented to read horizontally. From the top down, the content will consist of:
    - The image "photos/mosaic-block.png" scaled to be 0.6" wide
    - Below the image, centered horizontally, place in small-caps "Project MOSAIC" split between two lines. Use \fontsize{16}{18}
    
## Back of the book

The "back cover" is the left half of the document. There will be two elements on this cover:

1. A white  box 5.5" wide and 8" high with rounded corners. 
    - Layer over this box place the contents of description-text.tex via an include command.
    - Center this white box 4.33" from the left with the top 1" below the top of the document.

2. Another white box describing the ISBNcode. LaTeX instructions for generating the code are in "ISBN-code.tex".
    - Place the bottom edge of the ISBN box 0.5" from the document bottom and 0.75" to the left of the left boundary of the spine.

## Notes

Throughout this description I have referred to translucent white boxes. Please parameterize both the color and the transparency of the white box so that I can explore options to make them more attractive.

