# Double Space Writing Environment

Double Space takes a series of files that comprise a story and can produce output, namely a manuscript suitable
for submission (that uses the super shitty format required by most publishers).

The idea is twofold:

* provide a structure for place elements of the story and assisting in the writing
* produce output useful for editing, revision, and submitting

## How it works

Your project has a folder.  At the top of that folder is a file called story.json that looks like so:

```json
{
  "story": {
    "contact-info": {
      "name": "Phillip Dick",
      "surname": "Dick",
      "address": "123 Any St\nWashington, DC\n20002",
      "phone-number": "202-555-1211",
      "email": "phillbaby@dickempire.info"
    },
    "story-info": {
      "title": "We Can Remember That For You Wholesale",
      "author": "Phillip K Dick",
      "keywords-for-header": "Remember That Wholesale"
    }
  }
}
```

If `story->contact-info->surname` is omitted, it is assumed to be last full word of `story->contact-info->name`.

Your project has folder called `draft`. In that folder are one ore more directories named `actNN` where "NN" is a
number.  Inside those directories are files named `sceneNN.md`.  These contain the story's scenes.  The entire
thing is stiche together with act1, scene1, act1, scene2, act2 scene3, etc.  Any other files inside the folders
are ignored.

The structure of the scene files is pretty basic:

* A blank lines ends the previous paragraph.
* a word or words surrounded by asterisks are considered italicized.

No other formatting is permitted.  The contents of the file also have front matter and back matter.  The front
matter is a series of questions and answers about the scene that can be useful for making sure the scene is
accomplishing what you want.  The back-matter is a series of notes representing what the reader has learned by the
end of this scene.

To render the entire store us `ds`.  `ds` has three main modes:

* `ds` - creates `story.html` in the current directory which will render a typographically present HTML version of the story, with scenes annotated, along with the questions/answers and notes.
* `ds --clean` does what `ds` does, but omits the metadata. You'll just see the story all together in `story-clean.html`
* `ds --manuscript` will produce `story.docx` file formatted in the horrnedous way that publications want their submissions formatted.  This will also make the following content changes:
  - anything italicized will be underlined (unless you specify `--real-italics`).
  - between each scene is a centered `#`
  - Proper typographic symbols will be replaced by ASCII simultations:
    - quotes are replaced by `"` or `'`
    - en dashes are replaced by hyphens
    - em dashes are repalced by two hyphens
    - ellipsis are replaced by three periods
    - a period followed by more that one space is replaced by a period followed by a single space
  - `ds` will fail if there are any spelling errors
