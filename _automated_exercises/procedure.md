# Procedures for generating automated exercises

I want to develop several *types* of exercise based on the vocabulary of each chapter.

## Short definitions

In this style of exercise, we will create short definitions for the highlighted vocabulary words in a chapter. 

- For Chap-NN-phrase.qmd the highlighted words are stored under _Words/chap_NN.txt.

- In development phase, let's work with Chap-06-functions.qmd, with highlighted words in _Words/chap_6.txt.

- Scan Chap-06-functions.qmd to set a context. Then, within this context, write five different, short, correct definitions for "algorithm." Also, write ten off-the-target definitions that are incorrect in some obvious way.
    i. Each definition should be no longer than about 30 words.
    ii. The correct definition does not have to describe every aspect of the meaning of the word, but should contain at least one important aspect.
    iii. The incorrect definitions should be obviously incorrect to someone who has read the chapter carefully. 
        - Incorrect definitions might negate an important aspect of the correct definition.
        - Incorrect definitions might use other highlighted words from the "Vocabulary review" section of _Words/chap_NN.txt but in an incoherent manner that is oblivious to their actual technical meaning.
        - Deliver the definitions in a YAML formatted file in the the directory _automated_exercises. The file should be named in the style "word.yml", for instance, "operationalization-definitions.yml".
        - the "justification" field of an invalid definition should provide suitable feedback that will highlight what is wrong about the definition.

An example of a definitions YAML file with two valid definitions and two invalid ones: operationalization.yml

```{yaml}
word: operationalization
for-chapter: 6
valid: 
  - The process of quantifying a systems dimension with a defined measurement process.
  - Developing a method for meaningfully measuring a real-world dimension.
invalid: 
  - text: |
      Building a model that can be used to operate a decision-making process.
    justification: |
      Operationalization is about defining quantities. It comes *before* model building. 
  - text: |
      Choosing which decision to make after comparing model outputs.
    justification: |
      This describes decision-making, not operationalization.
```

### Ideas for generating invalid definitions

1. If a valid definition involves a from-to statement, in the invalid definition reverse them. 
   a. Example
       - Valid: "A complete operational description of the process that turns a function's inputs into its output."
       - For invalid definition, reverse inputs and output.



Test 1:
    - Read Chap-06-functions.qmd to establish a context.
    - Generate valid and invalid definitions for "algorithm" within that context, formatting them as YAML in the above scheme and writing them to _automated_exercises/algorithm-definitions.yml.
    - The author will scan that yml file to judge how things are going.


## Construction of definitions

For Chapter N, look at the file _Words/chap_N.txt to identify the new words introduced in that chapter as well as the review words used in Chapter N that were introduced in previous chapters.

For each of the new words for Chapter N, generate a YAML file of five valid and ten invalid definitions. For instance, for word W, create a file _automated_exercises/Chap-N/W.yml holding the YAML object.

If the Chap-N/ subdirectory does not yet exist, create it. 

## Construction of {devoirs3} questions


Once the YAML file is generated for word W, I will want to create {devoirs3} questions using them. There will be two types of questions:


1. "Only one of the following is a valid description of W. Mark that one."

2. "Two of the following are valid descriptions of W. The other three are not. Mark both of the VALID descriptions." 


For each type, the valid and invalid descriptions will be selected at random. Use as the random seed the date (e.g. 20271110) followed by the chapter number N.

Use R code like this to generate the set of valid and invalid descriptions for the two types of questions:

```r
one_correct <- function(word) {
  definitions <- yaml::read_yaml("_automated_exercises/Chap-06/arg.yml")
  choices <- c(
    lapply(sample(definitions$valid, 1), function(text) {
      list(text = text, correct = TRUE, feedback = "Correct.")
    }),
    lapply(sample(definitions$invalid, 3), function(definition) {
      list(text = definition$text, correct = FALSE, feedback = definition$justification)
    })
  )
  choices <- choices[sample.int(length(choices))]

  choices
}
three_incorrect <- function(word) {
  definitions <- yaml::read_yaml("_automated_exercises/Chap-06/arg.yml")
  choices <- c(
    lapply(sample(definitions$valid, 2), function(text) {
      list(text = text, correct = FALSE, feedback = "Choose the **invalid** descriptions, not this valid description.")
    }),
    lapply(sample(definitions$invalid, 3), function(definition) {
      list(text = definition$text, correct = TRUE, 
      feedback = paste("Good. This is indeed an invalid description. Why?", definition$justification)
    })
  )
  choices <- choices[sample.int(length(choices))]

  choices
}
```


For word W in Chapter N, create a file _automated_exercises/Chap-N/W-one.qmd to hold the {devoirs3} markup to create the first type of question with one correct description and three incorrect ones. Do not put the R code in the file. Rather, run the `one_correct()` R function on the side to generate the choices, typing them out verbatim in a "devoirs_choices" chunk that is human readable and editable. Next, insert the phrase contained in (1) above. Finally, add to the qmd file an R chunk that uses `devoirs_selection()` that, when compiled by the author, will create the HTML widget for the question. 

Similarly, for word W in Chapter N, create _automated_exercises/Chap-N/W-one.qmd using `three_incorrect()` to generate the choices, formatting these verbatim as a "devoirs_choices" chunk. Then add phrase (2) above and finally apply `devoirs_selection()` to create the HTML widget.

In both cases, `devoirs_selection()` will require a "label=" input. Make this "W-N-one" and "W-N-two" for the two types of questions, respectively. 

Note that the "devoirs_choices" chunk is not a simple translation of the YAML in the choices. Its contents will look like this:

```{devoirs_choices functions_6_two_choices}
- 'A named model component that relates input dimensions to an output dimension.':
    correct: false
    feedback: Choose the **invalid** descriptions, not this valid description.
- 'A process that takes an output and reconstructs the inputs that must have produced it.':
    correct: true
    feedback: |
      Good. This is indeed an invalid description. Why? The chapter describes functions as transforming inputs into outputs, not reversing that direction.
```

