# Tabs vs. Spaces - Why we chose tabs

- Salesforce has a maximum of 3 MB allowed for code
  - This means a total maximum of 3,000,000 characters can be used in an org
- Some code/characters are NOT counted against that limit:
  - Test classes and test methods
  - Managed package code is not included in your total
- What IS counted?
  - Spaces before a line begins
  - Spaces and tabs input on their own lines with no code around them
  - Indents; 4 spaces / 4 characters vs 1 tab / 1 character
  - It's important to note that editing a file directly in Salesforce either via the developer console or the standard UI will convert all tabs to spaces. With larger classes this can increase your character usage by a significant amount if you're not careful
  - Some will argue that a properly designed and coded org should never approach this limit, but it's not unheard of that orgs in the past have had to increase this limit: https://releasenotes.docs.salesforce.com/en-us/summer18/release-notes/rn_apex_code_size_limit.htm
  - The biggest point to take away from this is consistency