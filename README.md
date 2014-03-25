# Growing Devs #

Growing Devs is a shared space for a group of developers who wish to write
about their work without the isolation that comes with a solo blog, or the
constraints of writing only for the company you work for. Here you'll find
content about the technology, techniques, and process the authors are using.

### Benefits ###

* Our topics can be polyglot, without language restriction
* The format helps motivate the people involved to write
* Becomes a resource in its own right
* Shared readership
* Combined pagerank
* Shared promotion within the group

## Getting Started ##

Please be sure to read our [Code of Conduct](https://github.com/growingdevs/growingdevs.github.io/blob/master/CODE_OF_CONDUCT.md) before contributing.

1. Clone the repo
2. `bundle install`
3. `foreman start`

## Publishing Process ##

1. Start a new post, using `thor post:create new-post-title`.
2. Edit `_posts/20XX-XX-XX-new-post-title.md`.
3. Run with `foreman start`
4. Create a PR with your new post
5. After a little bit of editorial review, merge and push

### Adding a New Author ###

1. Run thor author:create "Author Name" author-name to build an author page for Author Name in /authors/author-name.html
2. Add the author to _config.yml with id: author-name, and name: Author Name
