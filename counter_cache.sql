-- args: (_tbl, _col, _fk)
CREATE OR REPLACE FUNCTION update_counter_cache() RETURNS TRIGGER AS $$
  DECLARE
    _tbl regclass := TG_ARGV[0];
    _col varchar  := TG_ARGV[1];
    _fk  varchar  := TG_ARGV[2];
    -- UPDATE posts SET comments_count = comments_count + 1 WHERE id = #{comments.post_id}
    _increment varchar := format('UPDATE %I SET %I = %I + 1 WHERE id = $1.%I', _tbl, _col, _col, _fk);
    _decrement varchar := format('UPDATE %I SET %I = %I - 1 WHERE id = $1.%I', _tbl, _col, _col, _fk);
  BEGIN
    IF (TG_OP = 'INSERT') THEN
      EXECUTE _increment USING NEW;
    ELSEIF (TG_OP = 'DELETE') THEN
      EXECUTE _decrement USING OLD;
    ELSEIF (TG_OP = 'UPDATE') THEN
      -- This is redundant unless the foreign key actually changes, but can't do dynamic columns on the IF
      -- Could be accomplished with a WHEN check on the TRIGGER, but would then need more than one trigger
      EXECUTE _decrement USING OLD;
      EXECUTE _increment USING NEW;
    END IF;
    RETURN NULL;
  END;
$$ LANGUAGE plpgsql;

-- Usage (simplified):
CREATE TABLE posts (id integer, comments_count integer);
CREATE TABLE comments (id integer, post_id integer);

CREATE TRIGGER update_posts_comments_count
  AFTER INSERT OR DELETE OR UPDATE ON comments
  FOR EACH ROW
  EXECUTE PROCEDURE update_counter_cache('posts', 'comments_count', 'post_id');

-- Test Cases:
INSERT INTO posts (id) VALUES (1);
INSERT INTO posts (id) VALUES (2);
INSERT INTO posts (id) VALUES (3);
INSERT INTO comments (id, post_id) VALUES (1, 1);
INSERT INTO comments (id, post_id) VALUES (1, 2);
SELECT comments_count FROM posts; -- 1, 1, 0
DELETE FROM comments WHERE id = 1;
SELECT comments_count FROM posts; -- 0, 1, 0
UPDATE comments SET post_id = 3 WHERE post_id = 2;
SELECT comments_count FROM posts; -- 0, 0, 1

-- For polymorphic associations:
CREATE TABLE comments_p (id serial, commentable_id integer, commentable_type character varying, CONSTRAINT posts_pkey PRIMARY KEY (id));

CREATE TRIGGER update_posts_comments_count
  AFTER INSERT OR UPDATE ON comments_p
  FOR EACH ROW
  WHEN (NEW.commentable_type = 'Post')
  EXECUTE PROCEDURE update_counter_cache('posts', 'comments_count', 'commentable_id');
CREATE TRIGGER update_posts_comments_count_on_delete
  AFTER DELETE ON comments_p
  FOR EACH ROW
  WHEN (OLD.favoriteable_type = 'Post')
  EXECUTE PROCEDURE update_counter_cache('posts', 'comments_count', 'commentable_id');
