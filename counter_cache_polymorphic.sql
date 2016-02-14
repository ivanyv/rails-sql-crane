-- Use `counter_cache.sql` and these triggers for polymorphic associations:
CREATE TABLE comments_p (id integer, commentable_id integer, commentable_type character varying);

CREATE TRIGGER update_posts_comments_count
  AFTER INSERT OR UPDATE ON comments_p
  FOR EACH ROW
  WHEN (NEW.commentable_type = 'Post')
  EXECUTE PROCEDURE update_counter_cache('posts', 'comments_count', 'commentable_id');

CREATE TRIGGER update_posts_comments_count_on_delete
  AFTER DELETE ON comments_p
  FOR EACH ROW
  WHEN (OLD.commentable_type = 'Post')
  EXECUTE PROCEDURE update_counter_cache('posts', 'comments_count', 'commentable_id');
