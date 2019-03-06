# Salesforce Developer Standards

This repository is intended to provide authoritative guidance for Salesforce developers building and maintaining customizations in ITA's Salesforce environments. It is intended to promote consistency, quality, and maintainability of the Salesforce code base at ITA, and should be understood and adhered to by anyone writing code that will be deployed to ITA's Salesforce environments. These standards were started after Salesforce had been in production use at ITA for over 4 years, so there is a significant backlog of technical and functional debt in the ITA's environments that will take a long time to refactor to adhere to these standards, but every opportunity to do so should be taken as quickly as possible. If you have an addition or change to propose for these standards, see the [What is the process?](#what-is-the-process) section below.

## Established Standards & Conventions

- *Use tabs* instead of spaces (Apex, HTML, Triggers, Lightning, etc. - does not apply to .xml files)
  - [Why?](../master/more_info/tabs.md)

- Team standard Salesforce development environment: WebStorm w/ Illuminated Cloud
  - Licenses are provided for both
  - You are free to use a different IDE/editor as long as it doesn't interfere with the repositories you contribute to, e.g. add extra/unwanted spaces, are able to modify the metadata you need to work on, etc.
    - Many people prefer to use Intellij w/ Illuminated Cloud but the company doesn't supply licenses for Intellij at this time
  - Does not apply to git. Use whatever git client you feel most comfortable with.
    - However, WebStorm has an included git client should be sufficient for anyone's needs.

- You should always bulkify your code and be aware of your governor usage
  - You might find yourself in a situation that makes it difficult to completely avoid queries/DMLs nested in a loop. If you think you've found such a situation, please point it out during a code review.
```java
// 10 SOQLs/ 10 DMLs
for(Integer i = 0; i < 10; i++){
  Account a = [SELECT Id, Name FROM Account LIMIT 10];
  a.Name = 'Account' + i;
  update a;
}
```
vs.
```java
// 1 SOQL / 1 DML
List<Account> accountList = [SELECT Id, Name FROM Account LIMIT 10];
for(Integer i = 0; i < 10; i++){
  accountList[i].Name = 'Account' + i;
}
update accountList;
```

- One trigger per object ([Salesforce recommended](https://developer.salesforce.com/blogs/developer-relations/2011/04/apex-trigger-tip-using-a-class-per-object-to-control-logic.html))
  - The reason for this is control the order of execution. When there are multiple triggers you can not guarantee which trigger will run first.
  - Having all of an object's trigger logic originating from one place allows it to be read and updated more efficiently.

- Never commit commented or obsolete code in your final commit. Retaining commented code during development is acceptable for reference or convenience, but delete it before a final commit and pull request.
  - Commenting out code goes against the reason version control exists; it will still be available by looking at the history.

- Test methods should follow this format: testMethodThatYouAreTesting_StateBeforeTestAndWhatIsBeingSetup_ExpectedResult
  - Without any knowledge of the class it is testing and without any knowledge of the business logic involved, you can look at the below name and know exactly what to expect:
    - `testCreateNewContact_AccountExistsBeforeCreationAndIsAssigned_ContactCreatedSuccessfull()` and `testCreateNewContact_AccountDoesNotExist_NoContactCreatedExceptionThrown()` vs. `testCreateNewContac1t()` and `testCreateNewContact2()`
  - The difference between these two is that in the longer method name you know which one is supposed to succeed and which one is to fail. You also know that the success and failure is based on having an account already created.
  - Long test names look ugly, but I promise you’ll get to love them when revisiting old code or tackling coverage of a class you’ve never seen before

## What is this?

- A repo dedicated to voting on standards that will be encouraged and (in some cases) enforced on new code and old code (when the opportunity arises).

## What is the process?

- Voting will occur in Slack. There will be roughly two days for everyone in the channel to vote.
  - To initiate a vote in Slack, enter the following: `/poll "Which do you prefer for code indentation?" "Tabs" "Spaces"`
  - If you would like to create a pull request then please create a branch off of 'master' and initate pull requests from your branch
    - If you do not have the appropriate permissions to do something, please let Christian Coleman or Mike Griswold know
- Larger, more abstract concepts like structuring or new pages with extreme detail can be addressed in Issues
  - We'd like this document to be relatively short in that a new developer can open this up and quickly see what we expect when they write code, and if they want more information it can be provided via further linking of separate documents

## TODO (best practices that are not approved yet)

- Consistency is key
  - Whatever best practices are decided need to be proliferated through all new code and when possible to our old code
  - This helps with readability and quality control

- Prefixes before class names are sometimes a good thing
  - Usually only in environments where multiple separate feature projects are working in the same code base
  - Prefixes also allow for developers to scroll directly to the classes their project has implemented
  - However, when generifying something for standard or shared objects it can be extremely useful to not prefix them and add good documentation so other projects can reuse that code; it could be useful to open a dialogue between the other developer projects and announce these new features and encourage them to use it
    - Ex: TRCR_CustomObjFactory and ContactFactory are both good names

- Naming is hugely important
  - Spend some time picking your function, class, and variable names
  - Favor longer and more descriptive names when in doubt

- Use JavaDocs to document public (not private) methods and also at the top of your class/trigger
![alt text](https://github.com/InternationalTradeAdministration/developer-best-practices/blob/master/images/java_doc_example.PNG "JavaDoc example")

- Use comments sparingly
  - A good name can take the place of a comment in most cases:
![alt text](https://github.com/InternationalTradeAdministration/developer-best-practices/blob/master/images/comment_example_before.PNG "Comment example - before refactor")
vs.
![alt text](https://github.com/InternationalTradeAdministration/developer-best-practices/blob/master/images/comment_example_after.PNG "Comment example - after refactor")

- Clean code is something that needs to be a priority and thought about in all design and implementation decisions
  - What makes a good developer is not writing clever code, but it’s making code that other developers can read - making easily readable code is a skill that must be learned and practiced. It isn’t taught in colleges (to my knowledge) but can be learned via someone like Robert C. Martin. Check out the following book: https://www.oreilly.com/library/view/clean-code/9780136083238/

- Keep comments updated
  - If a comment above a regex says ‘// grab only alphanumeric characters’ and then you change the regex to include or exclude other characters then you need to update the comment so that future readers are not surprised, confused, or mislead

- Test methods MUST test something! They should not be there to simply provide code coverage. Everyone hates doing code coverage and test classes but I’ve found countless bugs in my code just from going through this practice

- Test class name format should be NameOfClassYouAreTestingTest
  - Or TestNameOfClassYouAreTesting? Or other? Definitely going to need some discussion.

- Each class should be covered at least 90% (75% is the minimum Salesforce requires, but this gives us a bunch of breathing room and ensures all but the most forced scenarios are accounted for)

- Formatting SOQL. I prefer the following SOQL format:
  - [ and ]; are on their own separate lines
  - The keywords are tabbed out one more time to keep them all in the same column
![alt text](https://github.com/InternationalTradeAdministration/developer-best-practices/blob/master/images/soql_format_example.PNG "SOQL format example")

## TODO

- insert mocking recommendation
  - FFLIB
  - caveats
- insert trigger framework recommendation
  - FFLIB
  - caveats
- insert data accessor/selector framework/strategy
  - FFLIB 
  - caveats