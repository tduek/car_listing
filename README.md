# Tommy's Cars

Live at [tommyscars.com][tommyscars.com].

This is a used car listing site that also tells you how good each deal is. Users can list their own cars or search for one they want to buy. They can also 'favorite' listings.

I built this over the last year whenever I had time, dedicating under 4 hours a week to it. I didn't write any tests for it since I'm also the only one working on it and I never thought I'd be showing it off to anyone.

## Noteworthy features

- Search & Sort
- `Backbone.Subset`
- `pushState` + server serves HTML snapshots for search-engine-indexable pages

### Search

The car search feature is the most involved in the app. Users can search based on year, make, model, price, and distance.

I calculate the distance between a user and listings on the fly, using a table I have with all the zipcodes and their latitudes and longitudes in the US, all in a single SQL query. I'm proud of the query that does that. First it narrows the table down to the zipcodes that *might* be within range, then it calculates the actual distances, even taking the curvature of the Earth into account! If you want to see it, it's in the `Zip` model.

### Sort

The coolest sort is sorting by best deal. This calculates how good of a deal each car is on the fly as a percentile ranking compared against all the other cars of the same model and year in the database.

This was fine for serving the 25 results of a single paginated page, but got super slow when I tried to get the total count of all the listings that matched the query. This took some thinking. You can see the solution in the `Listing` model.

### `Backbone.Subset`

A problem came up when I added listing favoriting. I had a Backbone Collection for the listings I displayed in the index and another for the listings the user owns. That introduced the potential for overlapping data where one car was in both Collections (as two separate Models). When I implemented favoriting, this overlap was especially annoying. A user could favorite a car, and it would be favorited in one collection but not the other.

My solution to this was a new Backbone class of Subset. An app holds all its models of a certain type in one main parentCollection and then it can have different subsets of that collection, of the same exact models.

Basically, whenever adding to a Subset, it checks whether the parent already has it. If it does, it uses the parent's model, else, it also adds it to the parent.

And then all my Models were in sync :)

## `pushState` + serving HTML snapshots

Google doesn't index JS apps, so this was just annoying. I just render the same views in Rails that Backbone would generate for the given URL, and I tack on all the Backbone kickoff logic.

Eventually, and this is a big eventually, I'd like to port the whole app over to Node and run Backbone in both the front and Backend somehow to serve up the HTML snapshots without any duplication of view code. I heard of Airbnb did something like this. Haven't looked into it much.


## TODO

- TESTS



