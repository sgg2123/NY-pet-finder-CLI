# NYC Adoptable Pet Search Command Line Application

For this project, we utilized the PetFinder API [Petfinder API](https://www.petfinder.com/) to allow our users to search by querying the API and save adoptable pets based on different sets of criteria to a Sqlite3 Database using ActiveRecord.

* As a user, I want to be able to enter my name to retrieve my records
* As a user, I want to enter a location and be given a random nearby restaurant suggestion
* As a user, I should be able to reject a suggestion and not see that restaurant suggestion again
* As a user, I want to be able to save to and retrieve a list of favorite restaurant suggestions

There are two user search flows:
1. A user selects a location in the NYC area which returns a list of up to 25 shelters in the desired borough. The user then selects a shelter from the list to view all pets available at that location. The user can then choose to view more information about a specific pet, view an image of the pet, and finally, decide whether they would like to save the pet to their personal database.
2. A user can select a type of pet for which they would like to search. They have the option to select an additional criteria to narrow their search (Age, Sex, Size, Breed) or can simply view 25 pets in the New York area. From this list, the user can select a pet for which they would like to see more information, view an image of the pet, and finally, decide whether they would like to save the pet to their personal database.

The user can also access their saved pets after "logging in":
1. From the main menu, a user can select to view their saved data. If they have previously saved a pet or multiple pets from one of the two search flows above, the saved pet and associated shelter information can be displayed in one of two tables:
  * Saved Pets Table - Here, a user can view all saved pets and associated pet details, including age, sex, size, breed(s), shelter, and contact information.
  * Shelters for Saved Pets Table - Here, a user can view all shelters and corresponding location and contact information for all pets they have saved.

## How to Install & Run Program

1. Fork and clone this repository to your local environment.
2. Navigate to the file directory from your terminal.
3. First, run 'bundle install' to install all required gems.
4. Run 'ruby bin/run.rb' to access the command line application.
5. Follow the prompts to execute searches or save data as a user.
  * Note that if you select to view a pet photo, a separate browser window will open and you will need to return to your terminal to resume the program.

## A Contributors Guide


## Code License


install instructions, a contributors guide and a link to the license for your code.



## Instructions

5. Prepare a video demo (narration helps!) describing how a user would interact with your working project.
    * The video should:
      - Have an overview of your project.(2 minutes max)
6. Prepare a presentation to follow your video.(3 minutes max)
    * Your presentation should:
      - Describe something you struggled to build, and show us how you ultimately implemented it in your code.
      - Discuss 3 things you learned in the process of working on this project.
      - Address, if anything, what you would change or add to what you have today?
      - Present any code you would like to highlight.   
7. *OPTIONAL, BUT RECOMMENDED*: Write a blog post about the project and process.