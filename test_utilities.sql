CREATE OR REPLACE FUNCTION assert_equal(a anyelement, b anyelement) RETURNS anyelement AS $$
  BEGIN
    IF (a <> b) THEN
      RAISE EXCEPTION '% not equal to %', a, b;
    END IF;
    RETURN a;
  END
$$ LANGUAGE plpgsql;

-- Usage:
-- Subquery must return a single column
SELECT assert_equal((SELECT ...), 'result');
