#Decisions:

Import data by running: 

    bin/import_votes <filename>

Start the server locally and navigate to:

    http:/localhost:3000/
    http:/localhost:3000/campaigns

## Use rspec for testing
This is just a personal preference.

## Leave database as SQLite until need proves otherwise
This can be easily changed later if required.
The database is only expected to have a small amount of data stored in it.

## Separate counting logic from saving logic.
This feels like a good separation of object.

## Group logic around the core object (Votes) rather than the actions (Importing/Counting)
I initially had the other way around, but this felt like a better file 
placement as it helped keep the related code together.

## Having multiple regular expressions
I have performed the line validation separately to the data extraction
so that I can ensure as much valid data as possible is captured.
This does have some negative performance costs, however at this stage I 
am willing to sacrifice speed for readability. If this is an issue the 
validation match can be rewritten to do both tasks - this would be
significantly more complex and difficult to understand, something i prefer
to avoid with regular expressions. 

## Move file processing to the initializer code in the counter
This feel like a more natural pass to do the processing rather than
only performing it lazily as required.

## Pass an IO object to the Counter
I figured this would foster thinking about what is processed, does it have
to be a file, can it be a direct stream of data instead? It also makes 
the test easier to write - and quicker to run as I don't have create a 
temp files.

## Data storage
I have chosen to store the data in a multiple tables - Campaign
and Choice. Because it a rails app.

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

