insert into main.users(id, username, email, password)
values
  (default, 'admin', 'admin@mail.com', 'admin'),
  (default, 'user1', 'user1@mail.com', 'qwerty');

insert into main.authors(id, name, creator_id, description)
values
  (default, 'J. K. Rowling', 1,
   'J.K. Rowling is the author of the seven Harry Potter books, which have sold over 500 million copies, ' ||
   'been translated into over 80 languages, and made into eight blockbuster films. She also wrote three short ' ||
   'series companion volumes for charity, including Fantastic Beasts and Where to Find Them, which later became ' ||
   'the inspiration for a new series of films. Harry''s story as a grown-up was later continued in a stage ' ||
   'play, Harry Potter and the Cursed Child, which J.K. Rowling wrote with playwright Jack Thorne and director ' ||
   'John Tiffany.In 2020, she returned to publishing for younger children with the fairy tale The Ickabog, ' ||
   'which she initially published for free online for children in lockdown, later donating all her book ' ||
   'royalties to help vulnerable groups affected by the Covid-19 pandemic.J.K. Rowling has received many ' ||
   'awards and honors for her writing, including for her detective series written under the name Robert ' ||
   'Galbraith. She supports a wide number of humanitarian causes through her charitable trust Volant, and ' ||
   'is the founder of the children''s care reform charity Lumos.For as long as she can remember, J.K. Rowling ' ||
   'wanted to be a writer, and is at her happiest in a room, making things up. She lives in Scotland with her ' ||
   'family.Mary GrandPré has illustrated more than twenty beautiful books, including The Noisy Paint Box by ' ||
   'Barb Rosenstock, which received a Caldecott Honor; Cleonardo, the Little Inventor, of which she is also ' ||
   'the author; and the original American editions of all seven Harry Potter novels. Her work has also appeared ' ||
    'in the New Yorker, the Atlantic Monthly, and the Wall Street Journal, and her paintings and pastels ' ||
   'have been shown in galleries across the United States. Ms. GrandPré lives in Sarasota, Florida, with ' ||
   'her family.'),

  (default, 'Andrzej Sapkowski', 1,
   'Andrzej Sapkowski is the author of the Witcher series and the Hussite Trilogy. He was born in 1948 in ' ||
   'Poland and studied economics and business, but the success of his fantasy cycle about Geralt of Rivia' ||
   'turned him into an international bestselling writer. Geralt''s story has inspired the hit Netflix show' ||
   'and multiple video games, has been translated into thirty-seven languages, and has sold millions of copies' ||
   'worldwide.');

insert into main.categories(id, name)
values
  (default, 'History'),
  (default, 'Poetry'),
  (default, 'Classic'),
  (default, 'Fantasy'),
  (default, 'Science Fiction'),
  (default, 'Horror'),
  (default, 'Adventure'),
  (default, 'Manga'),
  (default, 'Travel'),
  (default, 'Science'),
  (default, 'Comics'),
  (default, 'Computer Science');

insert into main.books(id, title, price, count, creator_id, author_id, description)
values
  (default, 'Harry Potter and the Prisoner of Azkaban', 40.99, 5, 1,
   (select id from core.authors where name ilike '%Rowling%'),
   'For twelve long years, the dread fortress of Azkaban held an infamous prisoner named Sirius Black. ' ||
   'Convicted of killing thirteen people with a single curse, he was said to be the heir apparent to the ' ||
   'Dark Lord, Voldemort.Now he has escaped, leaving only two clues as to where he might be headed: Harry ' ||
   'Potter''s defeat of You-Know-Who was Black''s downfall as well. And the Azkaban guards heard Black ' ||
   'muttering in his sleep, He''s at Hogwarts . . . he''s at Hogwarts.Harry Potter isn''t safe, not even ' ||
   'within the walls of his magical school, surrounded by his friends. Because on top of it all, there may ' ||
   'well be a traitor in their midst.'),

  (default, 'The Last Wish: Introducing the Witcher', 20.00, 15, 1,
   (select id from core.authors where name ilike '%Sapkowski%'),
   'Geralt the Witcher--revered and hated--holds the line against the monsters plaguing humanity in this ' ||
   'collection of adventures, the first chapter in Andrzej Sapkowski''s groundbreaking epic fantasy series ' ||
   'that inspired the hit Netflix show and the blockbuster video games. Geralt is a Witcher, a man ' ||
   'whose magic powers, enhanced by long training and a mysterious elixir, have made him a brilliant ' ||
   'fighter and a merciless hunter. Yet he is no ordinary killer. His sole purpose: to destroy the monsters ' ||
   'that plague the world. But not everything monstrous-looking is evil and not everything fair is ' ||
   'good . . . and in every fairy tale there is a grain of truth.');

insert into main.authors_to_categories(author_id, category_id)
values
  ((select id from core.authors where name ilike '%Sapkowski%'),
   (select id from core.categories where name ilike '%Fantasy%')),
  ((select id from core.authors where name ilike '%Rowling%'),
   (select id from core.categories where name ilike '%Fantasy%')),
  ((select id from core.authors where name ilike '%Rowling%'),
   (select id from core.categories where name ilike '%Adventure%')),
   ((select id from core.authors where name ilike '%Sapkowski%'),
    (select id from core.categories where name ilike '%Adventure%'));

insert into main.books_to_categories(book_id, category_id)
values
  ((select id from core.books where title ilike '%The Last Wish: Introducing the Witcher%'),
    (select id from core.categories where name ilike '%Adventure%')),
  ((select id from core.books where title ilike '%Harry Potter and the Prisoner of Azkaban%'),
   (select id from core.categories where name ilike '%Adventure%'));