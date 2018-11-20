# Developer Best Practices (Draft)

## What is this?
A central place to discuss and establish some best practices. I think one of the biggest hurdles when deciding best practices is getting an overall consensus. Another major hurdle is the sheer number of best practices that each developer could suggest. We want the best practice document to be small/concise enough for a new developer to consume without feeling overwhelmed. 

## What is the process?
Using Github's native features we can vote on things, discuss them in comments, manage pull requests for better suggestions, etc.

## (DISCUSSION STARTED - PLEASE VOTE ON THE FOLLOWING, ADD COMMENTS, MAKE SUGGESTIONS, MAKE PULL REQUESTS, ETC.)

- Recommended development environment: WebStorm w/ Illuminated Cloud
  - Licenses are provided for both
  - You are free to use a different IDE/editor as long as it doesn't interfere with the repository's you contribute to, e.g. add extra/unwanted spaces, are able to modify the metadata you need to work on, etc.
    - Many people prefer to use Intellij w/ Illuminated Cloud but the company doesn't supply licenses 
- No SOQLs in for loops, you must bulkify!
```
for(Integer i = 0; i < 10; i++){
	Account a = [SELECT Id, Name FROM Account LIMIT 10];
	a.Name = 'Account' + i;
	update a;
}
```
- Use tabs instead of spaces 
  - Character counts and aesthetics 
- One trigger per object 
  - Can’t guarantee which one runs first if not

## (PERSONAL BEST PRACTICES - DISCUSSION COMING LATER)

- Prefixes before class names are sometimes a good thing 
  - Usually only in environments where multiple separate feature projects are working in the same code base 
  - Prefixes also allow for developers to scroll directly to the classes their project has implemented 
  - However, when generifying something for standard or shared objects it can be extremely useful to not prefix them and add good documentation so other projects can reuse that code; it could be useful to open a dialogue between the other developer projects and announce these new features and encourage them to use it 
    - Ex: TRCR_CustomObjFactory and ContactFactory are both good names 
- Naming is hugely important 
  - Spend some time picking your function, class, and variable names 
  - Favor longer and more descriptive names when in doubt 
- Use JavaDocs to document public (not private) methods and also at the top of your class/trigger 
  - Ex: 

(IMG)

- Use comments sparingly 
  - A good name can take the place of a comment in most cases: 

(IMG)

Vs. 

(IMG)

- Clean code is something that needs to be a priority and thought about in all design and implementation decisions 
  - What makes a good developer is not writing clever code, but it’s making code that other developers can read - making easily readable code is a skill that must be learned and practiced. It isn’t taught in colleges (to my knowledge) but can be learned via someone like Robert C. Martin. Check out the following book: https://www.oreilly.com/library/view/clean-code/9780136083238/  
- Never comment out old code and submit that to version control
  - Commenting out code goes against the very reason version control exists 
  - It will still be available by looking at past commits 
- Keep comments updated 
  - If a comment above a regex says ‘// grab only alphanumeric characters’ and then you change the regex to include or exclude other characters then you need to update the comment so that future readers are not surprised, confused, or mislead 
- Test methods should follow this format: testMethodThatYouAreTesting_StateBeforeTestAndWhatIsBeingSetup_ExpectedResult 
  - Without any knowledge of the class it is testing and without any knowledge of the business logic involved, you can look at the below name and know exactly what to expect: 
`testCreateNewContact_AccountExistsBeforeCreationAndIsAssigned_ContactCreatedSuccessfull()`
`testCreateNewContact_AccountDoesNotExist_NoContactCreatedExceptionThrown()`
Vs.
`testCreateNewContac1t()`
`testCreateNewContact2()`
  - The difference between these two is that in the longer method name you know which one is supposed to succeed and which one is to fail. You also know that the success and failure is based on having an account already created. 
  - Long test names look ugly, but I promise you’ll get to love them when revisiting old code or tackling coverage of a class you’ve never seen before 
- Test methods MUST test something! They should not be there to simply provide code coverage. Everyone hates doing code coverage and test classes but I’ve found countless bugs in my code just from going through this practice 
- Test class name format should be NameOfClassYouAreTestingTest 
- Each class should be covered at least 90% (75% is the minimum Salesforce requires, but this gives us a bunch of breathing room and ensures all but the most forced scenarios are accounted for) 
- Formatting SOQL. I prefer the following SOQL format: 

(IMG)
  
  - [ and ]; are on their own separate lines
  - The keywords are tabbed out one more time to keep them all in the same column 
  - I’ve seen some people use a variation of this where they do something like this: 

(IMG)

  - I think this can get really ugly if there are a bunch of fields, but I understand why they do it (to easily see the fields that are referenced) and thereby making it easier to add new ones 

## TODO

- insert mocking recommendation
  - FFLIB
- insert trigger framework recommendation
  - FFLIB
- insert data accessor/selector framework/strategy
  - FFLIB 