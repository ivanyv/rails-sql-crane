CREATE OR REPLACE FUNCTION assert_equal(a varchar, b varchar) RETURNS varchar AS $$
  BEGIN
    IF (a <> b) THEN
      RAISE EXCEPTION '% not equal to %', a, b;
    END IF;
    RETURN 'SUCCESS';
  END
$$ LANGUAGE plpgsql;

-- Usage:
-- Subquery must return a single column
SELECT assert_equal((SELECT ...)::varchar, 'result');
