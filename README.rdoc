#Decisions:

Access: start the server and navigate to either:

* root path
* /campaigns

## Use rspec for testing
This is just a personal preference.

## Leave database as SQLite until need proves otherwise
This can be easily changed later if required.
The database is only expected to have a small amount of data stored in it.

## Separate counting logic from saving logic.

## Group logic around the core object (Votes) rather than the actions (Importing/Counting)
This will help to keep the related code together.
I have moved all the code to a single file, one of the last steps will
be to split out calles to individual files if required.

## Have multiple regular expressions
I have performed the line validation separately to the data extraction
so that I can ensure as much valid data as possible is captured.

## Move file processing to the initializer code in the counter
This feel like a more natural pass to do the processing rather than
only performing it lazily as required.

## Pass an IO object to the Counter
I figured this would foster thinking about what is processed, does it have
to be a file? It also makes the test easier to write (and quicker) as I
don't have create a temp file for each one.

## Data storage
I have choosen to store the data in a denormalized form (i.e. Campaign
and Choice AR object). Why, because it a rails app and storing it as json
on the object would be crazy.

## UI testing
I have not written any test for:

* the campaigns controller
* Web page integration testing

The reason for this is one of time, in a real world app I would have
added an integration tests only, as this would have covered the controller
use-case.  If in the future I added any logic to the controller, I would
then add a controller test as well.

NOTE: I have manually tested both the views.

If you would like to see this in practise I may update the repo to
include the tests when I have some free time - Friday afternoon.

