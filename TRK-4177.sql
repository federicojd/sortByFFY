

-- SET DEFINE OFF;
-- create or replace TYPE OBJECT_CHANGE AS OBJECT(
--   NAME  VARCHAR2(32767),
--   FFY   Integer,
--   TEXT  VARCHAR2(32767)
-- );
-- create or replace TYPE changesListType AS TABLE OF VARCHAR2(32767);
-- create or replace TYPE OBJECT_CHANGE_TABLE AS TABLE OF OBJECT_CHANGE;

CREATE OR REPLACE FUNCTION sortByFFY(changes IN VARCHAR2) 
RETURN VARCHAR2 AS
-- RETURN OBJECT_CHANGE_TABLE AS
	  result varchar2(32767);
    
    -- Changes in a big String, a <BR> is added to the end of the string
    changesString   VARCHAR2(32767) := changes || '<BR>'; 
    brIndex         Integer;
    currentIndex    Integer := 1;
    changesList     changesListType := changesListType();

    ffyRowStart     VARCHAR2(100) := '&nbsp;&nbsp;';
    ffyRowStart2    VARCHAR2(100) := '+ Increase funds';
    totalRowStart     VARCHAR2(100) := '<i>Total project cost';
    ffyIndex Integer;

    name VARCHAR2(2000) := '';
    FFY Integer;
    description  VARCHAR2(2000) := '';
    -- Object Change
    changeObjetc  OBJECT_CHANGE;
    -- Array of Changes
    changesArray  OBJECT_CHANGE_TABLE := OBJECT_CHANGE_TABLE(); 
    -- Temporary Change Object needed
    changeTmp OBJECT_CHANGE;  

  BEGIN

    LOOP
        brIndex := INSTR(changesString, '<BR>', currentIndex);
        EXIT WHEN brIndex = 0;
        changesList.EXTEND;
        changesList(changesList.COUNT) := SUBSTR(changesString, currentIndex, brIndex - currentIndex);
        currentIndex := brIndex + 4;
    END LOOP;

    result := '';

    -- Add elements 
    FOR i IN changesList.FIRST .. changesList.LAST  LOOP 

      if INSTR(changesList(i), ffyRowStart) = 0 and INSTR(changesList(i), totalRowStart) = 0 then
          -- If there changes, sort & concat & delete them
          if changesArray.COUNT > 0 then
            -- Sort changes by FFY
            FOR i IN changesArray.FIRST .. changesArray.LAST  LOOP
                FOR j IN changesArray.FIRST .. (changesArray.LAST-1) LOOP
                    if changesArray(j).FFY > changesArray(j + 1).FFY then
                        changeTmp := changesArray(j);
                        changesArray(j) := changesArray(j + 1);
                        changesArray(j + 1) := changeTmp;
                    end if;
                end LOOP;           
            END LOOP;
            -- Concat sorted changes
            FOR i IN changesArray.FIRST .. changesArray.LAST LOOP
              result := result || changesArray(i).TEXT || '<br>';
            END LOOP;
            -- Delete array of changes
            changesArray.Delete();
          end if;
          -- Concat Fund Name
          result := result || changesList(i) || '<BR>';
          -- Store Fund Name to use in the Array of changes
          name := changesList(i);
      end if;

      -- For each one of the changes
      if INSTR(changesList(i), ffyRowStart) > 0 then

          -- Look for FFY in the string and extract the FFY year
          ffyIndex := INSTR(changesList(i), ' FFY ') + 5;
          ffy := SUBSTR(changesList(i), ffyIndex, 2);
          -- Change - Complete line
          description := changesList(i);
          -- Create an array of FFYs
          changesArray.EXTEND;
          changesArray(changesArray.COUNT) := OBJECT_CHANGE (name,ffy,description);
      end if;
      
      -- If the iteration reach the last line "<i>Total project cost.."
      -- Will run the sort & concat & delete process for the last time
      -- This should be encapsulated in another function in order to KISS
      if INSTR(changesList(i), totalRowStart) > 0 then
          -- If there changes, sort & concat & delete them
          if changesArray.COUNT > 0 then
            -- Sort changes by FFY
            FOR i IN changesArray.FIRST .. changesArray.LAST  LOOP
                FOR j IN changesArray.FIRST .. (changesArray.LAST-1) LOOP
                    if changesArray(j).FFY > changesArray(j + 1).FFY then
                        changeTmp := changesArray(j);
                        changesArray(j) := changesArray(j + 1);
                        changesArray(j + 1) := changeTmp;
                    end if;
                end LOOP;           
            END LOOP;
            -- Concat sorted changes
            FOR i IN changesArray.FIRST .. changesArray.LAST LOOP
              result := result || changesArray(i).TEXT || '<br>';
            END LOOP;
            -- Delete array of changes
            changesArray.Delete();
          end if;
          -- Concat Total line "<i>Total project cost.."
          result := result || changesList(i) || '<BR>';
      end if;
    END LOOP;
      
    return result;
end sortByFFY;

