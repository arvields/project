PGDMP  "                     |            classification    16.0    16.0 �    C           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            D           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            E           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            F           1262    110119    classification    DATABASE     �   CREATE DATABASE classification WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_Philippines.1252';
    DROP DATABASE classification;
                postgres    false                        2615    110272    knowledge_base    SCHEMA        CREATE SCHEMA knowledge_base;
    DROP SCHEMA knowledge_base;
                postgres    false                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            G           0    0    SCHEMA public    COMMENT         COMMENT ON SCHEMA public IS '';
                   postgres    false    6            H           0    0    SCHEMA public    ACL     Q   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
                   postgres    false    6            $           1255    110273 f   calculate_fish_ratios(integer, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric) 	   PROCEDURE     �  CREATE PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric)
    LANGUAGE plpgsql
    AS $$
DECLARE
    bd_bl_ratio NUMERIC;
    pdl_bl_ratio NUMERIC;
    hl_bl_ratio NUMERIC;
    snl_bl_ratio NUMERIC;
    ed_bl_ratio NUMERIC;
    pal_bl_ratio NUMERIC;
    vafl_bl_ratio NUMERIC;
BEGIN
    -- Calculate the ratios
    bd_bl_ratio := bd / bl;
    pdl_bl_ratio := pdl / bl;
    hl_bl_ratio := hl / bl;
    snl_bl_ratio := snl / bl;
    ed_bl_ratio := ed / bl;
    pal_bl_ratio := pal / bl;
    vafl_bl_ratio := vafl / bl;

    -- Insert the ratios into the fish_ratio table
    INSERT INTO public.fish_ratio (sample_no, "BD/BL_ratio", "PDL/BL_ratio", "HL/BL_ratio", "SnL/BL_ratio", "ED/BL_ratio", "PAL/BL_ratio", "VAFL/BL_ratio")
    VALUES (sample_no, bd_bl_ratio, pdl_bl_ratio, hl_bl_ratio, snl_bl_ratio, ed_bl_ratio, pal_bl_ratio, vafl_bl_ratio);
END;
$$;
 �   DROP PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric);
       public          postgres    false    6            I           0    0 �   PROCEDURE calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric)    ACL     �  GRANT ALL ON PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric) TO lab_examiner;
GRANT ALL ON PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric) TO research_assistant;
GRANT ALL ON PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric) TO study_leader;
          public          postgres    false    292                       1255    110274    count_all_samples()    FUNCTION     �   CREATE FUNCTION public.count_all_samples() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  sample_count INT;
BEGIN
  SELECT COUNT(DISTINCT sample_no) INTO sample_count
  FROM sample_master;

  RETURN sample_count;
END
$$;
 *   DROP FUNCTION public.count_all_samples();
       public          postgres    false    6            J           0    0    FUNCTION count_all_samples()    ACL     �   GRANT ALL ON FUNCTION public.count_all_samples() TO lab_examiner;
GRANT ALL ON FUNCTION public.count_all_samples() TO research_assistant;
GRANT ALL ON FUNCTION public.count_all_samples() TO study_leader;
          public          postgres    false    262                       1255    110275    get_next_mdecision_no()    FUNCTION     #  CREATE FUNCTION public.get_next_mdecision_no() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    next_mdecision_no INTEGER;
BEGIN
    SELECT COALESCE(MAX(mdecision_no), 0) + 1 INTO next_mdecision_no
    FROM public.morphometric_decision;
    
    RETURN next_mdecision_no;
END;
$$;
 .   DROP FUNCTION public.get_next_mdecision_no();
       public          postgres    false    6                       1255    110276 1   insert_flexion_family_scorecard(integer, integer) 	   PROCEDURE     N  CREATE PROCEDURE public.insert_flexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    margin_no_value NUMERIC;
BEGIN
    -- Fetch the margin_no value from public.sample_master, default to 0 if NULL
    SELECT COALESCE(margin_no, 0) INTO margin_no_value
    FROM public.sample_master
    WHERE sample_no = p_sample_no;

    IF p_fgroup_no IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19) 
        AND (SELECT stage_name FROM public.sample_master WHERE sample_no = p_sample_no) = 'Flexion' THEN
        INSERT INTO public.family_scorecard (sample_no, ffamily_name, bd_score, ed_score, hl_score, pdl_score, snl_score, pal_score, vafl_score)
        SELECT p_sample_no, k.ffamily_name,
            CASE WHEN (k.bd_range IS NULL) THEN NULL
                WHEN (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.bd_range) - margin_no_value 
                    AND (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.bd_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.ed_range IS NULL) THEN NULL
                WHEN (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.ed_range) - margin_no_value 
                    AND (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.ed_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.hl_range IS NULL) THEN NULL
                WHEN (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.hl_range) - margin_no_value 
                    AND (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.hl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.pdl_range IS NULL) THEN NULL
                WHEN (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.pdl_range) - margin_no_value 
                    AND (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.pdl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.snl_range IS NULL) THEN NULL
                WHEN (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.snl_range) - margin_no_value 
                    AND (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.snl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.pal_range IS NULL) THEN NULL
                WHEN (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.pal_range) - margin_no_value 
                    AND (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.pal_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.vafl_range IS NULL) THEN NULL
                WHEN (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.vafl_range) - margin_no_value 
                    AND (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.vafl_range) + margin_no_value THEN 1 ELSE 0 END
        FROM knowledge_base.flexion_stage k
        WHERE k.fgroup_no = p_fgroup_no;
    END IF;
END;
$$;
 g   DROP PROCEDURE public.insert_flexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer);
       public          postgres    false    6            	           1255    110277 *   insert_flexion_family_scorecard_function()    FUNCTION     �   CREATE FUNCTION public.insert_flexion_family_scorecard_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.insert_flexion_family_scorecard(NEW.sample_no, NEW.fgroup_no);
    RETURN NEW;
END;
$$;
 A   DROP FUNCTION public.insert_flexion_family_scorecard_function();
       public          postgres    false    6            
           1255    110278    insert_genus_scorecard()    FUNCTION     	  CREATE FUNCTION public.insert_genus_scorecard() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
	INSERT INTO public.genus_scorecard (sample_no, ffamily_name, fgenus_name, dorsal_count_score, anal_count_score, pectoral_count_score, caudal_count_score, vertebrae_count_score, pelvic_count_score)
	SELECT NEW.sample_no, NEW.ffamily_name, k.fgenus_name,
		CASE WHEN (k.dorsal_range IS NULL) THEN NULL
			WHEN (SELECT dorsal_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER >= LOWER(k.dorsal_range)
				AND (SELECT dorsal_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER <= UPPER(k.dorsal_range) THEN 1 ELSE 0 END,
		CASE WHEN (k.anal_range IS NULL) THEN NULL
			WHEN (SELECT anal_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER >= LOWER(k.anal_range)
				AND (SELECT anal_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER <= UPPER(k.anal_range) THEN 1 ELSE 0 END,
		CASE WHEN (k.pectoral_range IS NULL) THEN NULL
			WHEN (SELECT pectoral_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER >= LOWER(k.pectoral_range)
				AND (SELECT pectoral_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER <= UPPER(k.pectoral_range) THEN 1 ELSE 0 END,
		CASE WHEN (k.caudal_range IS NULL) THEN NULL
			WHEN (SELECT caudal_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER >= LOWER(k.caudal_range)
				AND (SELECT caudal_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER <= UPPER(k.caudal_range) THEN 1 ELSE 0 END,
		CASE WHEN (k.vertebrae_range IS NULL) THEN NULL
			WHEN (SELECT vertebrae_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER >= LOWER(k.vertebrae_range)
				AND (SELECT vertebrae_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER <= UPPER(k.vertebrae_range) THEN 1 ELSE 0 END,
		CASE WHEN (k.pelvic_range IS NULL) THEN NULL
			WHEN (SELECT pelvic_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER >= LOWER(k.pelvic_range)
				AND (SELECT pelvic_count FROM public.sample_master WHERE sample_no = NEW.sample_no)::INTEGER <= UPPER(k.pelvic_range) THEN 1 ELSE 0 END
	FROM knowledge_base.family_genus k
	WHERE k.ffamily_name = NEW.ffamily_name;

	RETURN NEW;
END;
$$;
 /   DROP FUNCTION public.insert_genus_scorecard();
       public          postgres    false    6                       1255    110279 5   insert_postflexion_family_scorecard(integer, integer) 	   PROCEDURE     [  CREATE PROCEDURE public.insert_postflexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    margin_no_value NUMERIC;
BEGIN
    -- Fetch the margin_no value from public.sample_master, default to 0 if NULL
    SELECT COALESCE(margin_no, 0) INTO margin_no_value
    FROM public.sample_master
    WHERE sample_no = p_sample_no;

    IF p_fgroup_no IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19) 
        AND (SELECT stage_name FROM public.sample_master WHERE sample_no = p_sample_no) = 'Post-flexion' THEN
        INSERT INTO public.family_scorecard (sample_no, ffamily_name, bd_score, ed_score, hl_score, pdl_score, snl_score, pal_score, vafl_score)
        SELECT p_sample_no, k.ffamily_name,
            CASE WHEN (k.bd_range IS NULL) THEN NULL
                WHEN (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.bd_range) - margin_no_value 
                    AND (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.bd_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.ed_range IS NULL) THEN NULL
                WHEN (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.ed_range) - margin_no_value 
                    AND (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.ed_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.hl_range IS NULL) THEN NULL
                WHEN (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.hl_range) - margin_no_value 
                    AND (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.hl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.pdl_range IS NULL) THEN NULL
                WHEN (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.pdl_range) - margin_no_value 
                    AND (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.pdl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.snl_range IS NULL) THEN NULL
                WHEN (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.snl_range) - margin_no_value 
                    AND (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.snl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.pal_range IS NULL) THEN NULL
                WHEN (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.pal_range) - margin_no_value 
                    AND (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.pal_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.vafl_range IS NULL) THEN NULL
                WHEN (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.vafl_range) - margin_no_value 
                    AND (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.vafl_range) + margin_no_value THEN 1 ELSE 0 END
        FROM knowledge_base.postflexion_stage k
        WHERE k.fgroup_no = p_fgroup_no;
    END IF;
END;
$$;
 k   DROP PROCEDURE public.insert_postflexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer);
       public          postgres    false    6                       1255    110280 .   insert_postflexion_family_scorecard_function()    FUNCTION     �   CREATE FUNCTION public.insert_postflexion_family_scorecard_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.insert_postflexion_family_scorecard(NEW.sample_no, NEW.fgroup_no);
    RETURN NEW;
END;
$$;
 E   DROP FUNCTION public.insert_postflexion_family_scorecard_function();
       public          postgres    false    6            (           1255    110281 4   insert_preflexion_family_scorecard(integer, integer) 	   PROCEDURE     X  CREATE PROCEDURE public.insert_preflexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    margin_no_value NUMERIC;
BEGIN
    -- Fetch the margin_no value from public.sample_master, default to 0 if NULL
    SELECT COALESCE(margin_no, 0) INTO margin_no_value
    FROM public.sample_master
    WHERE sample_no = p_sample_no;

    IF p_fgroup_no IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19) 
        AND (SELECT stage_name FROM public.sample_master WHERE sample_no = p_sample_no) = 'Pre-flexion' THEN
        INSERT INTO public.family_scorecard (sample_no, ffamily_name, bd_score, ed_score, hl_score, pdl_score, snl_score, pal_score, vafl_score)
        SELECT p_sample_no, k.ffamily_name,
            CASE WHEN (k.bd_range IS NULL) THEN NULL
                WHEN (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.bd_range) - margin_no_value 
                    AND (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.bd_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.ed_range IS NULL) THEN NULL
                WHEN (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.ed_range) - margin_no_value 
                    AND (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.ed_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.hl_range IS NULL) THEN NULL
                WHEN (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.hl_range) - margin_no_value 
                    AND (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.hl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.pdl_range IS NULL) THEN NULL
                WHEN (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no) IS NULL THEN NULL
                WHEN (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.pdl_range) - margin_no_value 
                    AND (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.pdl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.snl_range IS NULL) THEN NULL
                WHEN (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.snl_range) - margin_no_value 
                    AND (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.snl_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.pal_range IS NULL) THEN NULL
                WHEN (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.pal_range) - margin_no_value 
                    AND (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.pal_range) + margin_no_value THEN 1 ELSE 0 END,
            CASE WHEN (k.vafl_range IS NULL) THEN NULL
                WHEN (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC >= LOWER(k.vafl_range) - margin_no_value 
                    AND (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = p_sample_no)::NUMERIC <= UPPER(k.vafl_range) + margin_no_value THEN 1 ELSE 0 END
        FROM knowledge_base.preflexion_stage k
        WHERE k.fgroup_no = p_fgroup_no;
    END IF;
END;
$$;
 j   DROP PROCEDURE public.insert_preflexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer);
       public          postgres    false    6                       1255    110282 -   insert_preflexion_family_scorecard_function()    FUNCTION     �   CREATE FUNCTION public.insert_preflexion_family_scorecard_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.insert_preflexion_family_scorecard(NEW.sample_no, NEW.fgroup_no);
    RETURN NEW;
END;
$$;
 D   DROP FUNCTION public.insert_preflexion_family_scorecard_function();
       public          postgres    false    6                       1255    110283 $   insert_shape_characteristic_result()    FUNCTION     �  CREATE FUNCTION public.insert_shape_characteristic_result() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Initialize variables to hold the characteristics, fgroup_no, and sample_no
    DECLARE
        bd_characteristics text;
        hl_characteristics text;
        ed_characteristics text;
        fgroup_no integer;
        sample_no integer;
    BEGIN
        -- Check the group_scorecard table for characteristics, fgroup_no, and sample_no
        SELECT INTO bd_characteristics, hl_characteristics, ed_characteristics, fgroup_no, sample_no
        CASE
            WHEN NEW.very_elongate = 1 THEN 'Very Elongate'
            WHEN NEW.elongate = 1 THEN 'Elongate'
            WHEN NEW.moderate = 1 THEN 'Moderate'
            WHEN NEW.deep = 1 THEN 'Deep'
            WHEN NEW.very_deep = 1 THEN 'Very Deep'
            ELSE NULL
        END,
        CASE
            WHEN NEW.small_head = 1 THEN 'Small Head'
            WHEN NEW.moderate_head = 1 THEN 'Moderate Head'
            WHEN NEW.large_head = 1 THEN 'Large Head'
            ELSE NULL
        END,
        CASE
            WHEN NEW.small_eye = 1 THEN 'Small Eye'
            WHEN NEW.moderate_eye = 1 THEN 'Moderate Eye'
            WHEN NEW.large_eye = 1 THEN 'Large Eye'
            ELSE NULL
        END
        FROM public.group_decision
        WHERE public.group_decision.fgroup_no = NEW.fgroup_no;

        -- Insert the sample_no, characteristics, and fgroup_no into the shape_characteristic_result table
        INSERT INTO public.shape_characteristic_result (sample_no, bd_characteristic, hl_characteristic, ed_characteristic, fgroup_no)
        VALUES (NEW.sample_no, bd_characteristics, hl_characteristics, ed_characteristics, NEW.fgroup_no);
        
        RETURN NEW;
    END;
END;
$$;
 ;   DROP FUNCTION public.insert_shape_characteristic_result();
       public          postgres    false    6            '           1255    110284    insert_summary_ranking()    FUNCTION     �  CREATE FUNCTION public.insert_summary_ranking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
	DECLARE
		meristic_sum_result NUMERIC;
		meristic_count INTEGER;
		morphometric_sum_result NUMERIC;
		morphometric_count INTEGER;
		combined_fish_scores NUMERIC;
		sample_rank INTEGER;
	BEGIN
		-- Calculate the meristic_sum by adding non-NULL values from columns
		-- dorsal_count_score to pelvic_count_score
		meristic_count := 0;
		meristic_sum_result := 0;
		IF EXISTS (SELECT 1 FROM public.genus_scorecard WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name) THEN
			SELECT
				COALESCE(dorsal_count_score, 0) +
				COALESCE(anal_count_score, 0) +
				COALESCE(pectoral_count_score, 0) +
				COALESCE(caudal_count_score, 0) +
				COALESCE(vertebrae_count_score, 0) +
				COALESCE(pelvic_count_score, 0)
			INTO meristic_sum_result
			FROM public.genus_scorecard
			WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name;

			SELECT
				(CASE WHEN dorsal_count_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN anal_count_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN pectoral_count_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN caudal_count_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN vertebrae_count_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN pelvic_count_score IS NOT NULL THEN 1 ELSE 0 END)
			INTO meristic_count
			FROM public.genus_scorecard
			WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name;
		END IF;
		
		-- Calculate the morphometric_sum and morphometric_count based on the
		-- public.family_scorecard table for the given id
		morphometric_count := 0;
		morphometric_sum_result := 0;
		IF EXISTS (SELECT 1 FROM public.family_scorecard WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name) THEN
			SELECT
				COALESCE(bd_score, 0) +
				COALESCE(ed_score, 0) +
				COALESCE(hl_score, 0) +
				COALESCE(pdl_score, 0) +
				COALESCE(snl_score, 0) +
				COALESCE(pal_score, 0) +
				COALESCE(vafl_score, 0)
			INTO morphometric_sum_result
			FROM public.family_scorecard
			WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;

			SELECT
				(CASE WHEN bd_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN ed_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN hl_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN pdl_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN snl_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN pal_score IS NOT NULL THEN 1 ELSE 0 END) +
				(CASE WHEN vafl_score IS NOT NULL THEN 1 ELSE 0 END)
			INTO morphometric_count
			FROM public.family_scorecard
			WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;
		END IF;

		-- Calculate the combined_scores using the formula you provided
		combined_fish_scores := (meristic_sum_result / meristic_count) + (morphometric_sum_result / morphometric_count);

		-- Update the rank column in the summary_ranking table
    	UPDATE public.summary_ranking AS t
    	SET rank = subquery.rank
    	FROM (
        	SELECT sample_no, combined_scores,
            	DENSE_RANK() OVER (PARTITION BY sample_no ORDER BY combined_scores DESC) AS rank
        	FROM public.summary_ranking
    	) AS subquery
   	 	WHERE t.sample_no = subquery.sample_no AND t.combined_scores = subquery.combined_scores;

		-- Assign the DENSE_RANK() value to sample_rank
		SELECT rank INTO sample_rank
		FROM (
			SELECT sample_no, combined_scores,
				DENSE_RANK() OVER (PARTITION BY sample_no ORDER BY combined_scores DESC) AS rank
			FROM public.summary_ranking
		) AS subquery
		WHERE subquery.sample_no = NEW.sample_no AND subquery.combined_scores = combined_fish_scores;

		-- Check if the conditions for including ffamily_name and fgenus_name are met
		IF 
			-- Check if fgroup_no from group_decision is not 19 and the other conditions
			(
				(COALESCE((SELECT fgroup_no FROM group_decision WHERE sample_no = NEW.sample_no), -1) < 19 AND
					(
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 7 AND morphometric_count = 7) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 6 AND morphometric_count = 7) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 6 AND morphometric_count = 6) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 5 AND morphometric_count = 6) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 5 AND morphometric_count = 5) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 4 AND morphometric_count = 5) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 4 AND morphometric_count = 4) OR
						(meristic_sum_result != 0 AND meristic_count != 6 AND morphometric_sum_result = 3 AND morphometric_count = 4) OR

						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 7 AND morphometric_count = 7) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 6 AND morphometric_count = 7) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 6 AND morphometric_count = 6) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 5 AND morphometric_count = 6) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 5 AND morphometric_count = 5) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 4 AND morphometric_count = 5) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 4 AND morphometric_count = 4) OR
						(meristic_sum_result != 0 AND meristic_count != 5 AND morphometric_sum_result = 3 AND morphometric_count = 4) OR

						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 7 AND morphometric_count = 7) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 6 AND morphometric_count = 7) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 6 AND morphometric_count = 6) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 5 AND morphometric_count = 6) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 5 AND morphometric_count = 5) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 4 AND morphometric_count = 5) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 4 AND morphometric_count = 4) OR
						(meristic_sum_result != 0 AND meristic_count != 4 AND morphometric_sum_result = 3 AND morphometric_count = 4)
					)
				)
				OR
				-- Include fgroup_no 19 in the logic of morphometric_count
				(
					COALESCE((SELECT fgroup_no FROM group_decision WHERE sample_no = NEW.sample_no), -1) = 19 AND
					(
						(morphometric_sum_result = 7 AND morphometric_count = 7) OR
						(morphometric_sum_result = 6 AND morphometric_count = 7) OR
						(morphometric_sum_result = 6 AND morphometric_count = 6) OR
						(morphometric_sum_result = 5 AND morphometric_count = 6) OR
						(morphometric_sum_result = 5 AND morphometric_count = 5) OR
						(morphometric_sum_result = 4 AND morphometric_count = 5) OR
						(morphometric_sum_result = 4 AND morphometric_count = 4) OR
						(morphometric_sum_result = 3 AND morphometric_count = 4)
					)
				)
			)
		THEN
			-- Insert the calculated summary values into public.summary_ranking
			INSERT INTO public.summary_ranking (sample_no, ffamily_name, fgenus_name, meristic_sum, morphometric_sum, combined_scores, "rank")
			VALUES (
				NEW.sample_no,
				NEW.ffamily_name,
				NEW.fgenus_name,
				meristic_sum_result || ' / ' || meristic_count,
				morphometric_sum_result || ' / ' || morphometric_count,
				combined_fish_scores,
				sample_rank
			);
		END IF;

		RETURN NEW;
	END;
	
$$;
 /   DROP FUNCTION public.insert_summary_ranking();
       public          postgres    false    6                       1255    110285 !   insert_to_classification_result()    FUNCTION     �  CREATE FUNCTION public.insert_to_classification_result() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO public.classification_result (sample_no, fgroup_no, ffamily_name, fgenus_name)
    SELECT
        NEW.sample_no,
		gd.fgroup_no,
        NEW.ffamily_name,
        NEW.fgenus_name
    FROM public.group_decision gd
    WHERE gd.sample_no = NEW.sample_no;
    RETURN NEW;
END;
$$;
 8   DROP FUNCTION public.insert_to_classification_result();
       public          postgres    false    6            %           1255    110286    sample_master_fish_ratio()    FUNCTION     �  CREATE FUNCTION public.sample_master_fish_ratio() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Call the stored procedure to calculate fish ratios
    CALL calculate_fish_ratios(NEW.sample_no, NEW.bd, NEW.bl, NEW.pdl, NEW.hl, NEW.snl, NEW.ed, NEW.pal, NEW.vafl);
    
    -- You can perform additional actions or validations here if needed
    
    -- Return the new row
    RETURN NEW;
END;
$$;
 1   DROP FUNCTION public.sample_master_fish_ratio();
       public          postgres    false    6            K           0    0 #   FUNCTION sample_master_fish_ratio()    ACL     �   GRANT ALL ON FUNCTION public.sample_master_fish_ratio() TO lab_examiner;
GRANT ALL ON FUNCTION public.sample_master_fish_ratio() TO research_assistant;
GRANT ALL ON FUNCTION public.sample_master_fish_ratio() TO study_leader;
          public          postgres    false    293            &           1255    110287 !   sample_master_meristic_decision()    FUNCTION     +  CREATE FUNCTION public.sample_master_meristic_decision() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Call the stored procedure to insert meristic decision
    CALL insert_meristic_decision(
        NEW.sample_no,
        NEW.dorsal_count,
        NEW.anal_count,
        NEW.pectoral_count,
        NEW.pelvic_count,
        NEW.caudal_count,
        NEW.vertebrae_count,
        NEW.myomeres_count
    );
    
    -- You can perform additional actions or validations here if needed
    
    -- Return the new row
    RETURN NEW;
END;
$$;
 8   DROP FUNCTION public.sample_master_meristic_decision();
       public          postgres    false    6            L           0    0 *   FUNCTION sample_master_meristic_decision()    ACL     �   GRANT ALL ON FUNCTION public.sample_master_meristic_decision() TO lab_examiner;
GRANT ALL ON FUNCTION public.sample_master_meristic_decision() TO research_assistant;
GRANT ALL ON FUNCTION public.sample_master_meristic_decision() TO study_leader;
          public          postgres    false    294                       1255    110288 ,   set_shape_characteristic_result_row_number()    FUNCTION       CREATE FUNCTION public.set_shape_characteristic_result_row_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set the result_id to the next value from the sequence
    NEW.result_id := nextval('shape_characteristic_result_seq');
    RETURN NEW;
END;
$$;
 C   DROP FUNCTION public.set_shape_characteristic_result_row_number();
       public          postgres    false    6                       1255    110289    update_classification_result()    FUNCTION     p  CREATE FUNCTION public.update_classification_result() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update the rank column in public.classification_result
    UPDATE public.classification_result
    SET rank = NEW.rank
    WHERE ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name AND sample_no = NEW.sample_no;

    -- Update the timestamp column with the current timestamp
    UPDATE public.classification_result
	SET sample_timestamp = NOW() + INTERVAL '8 hours'
	WHERE ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name AND sample_no = NEW.sample_no;

    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.update_classification_result();
       public          postgres    false    6            )           1255    110637 *   update_family_scorecard_morphometric_sum()    FUNCTION     �  CREATE FUNCTION public.update_family_scorecard_morphometric_sum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    morphometric_sum_result NUMERIC;
    morphometric_count INTEGER;
BEGIN
    morphometric_sum_result := 0;
    morphometric_count := 0;

    -- Check if the record exists in family_scorecard
    IF EXISTS (
        SELECT 1
        FROM public.family_scorecard
        WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name
    ) THEN
        -- Calculate the sum of specified columns
        SELECT
            COALESCE(bd_score, 0) +
            COALESCE(ed_score, 0) +
            COALESCE(hl_score, 0) +
            COALESCE(pdl_score, 0) +
            COALESCE(snl_score, 0) +
            COALESCE(pal_score, 0) +
            COALESCE(vafl_score, 0)
        INTO morphometric_sum_result
        FROM public.family_scorecard
        WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;

        -- Count the total number of non-null values
        SELECT
            (CASE WHEN bd_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN ed_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN hl_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN pdl_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN snl_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN pal_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN vafl_score IS NOT NULL THEN 1 ELSE 0 END)
        INTO morphometric_count
        FROM public.family_scorecard
        WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;

        -- Update the morphometric_sum column
        UPDATE public.family_scorecard
        SET morphometric_sum = CASE
            WHEN morphometric_count > 0 THEN morphometric_sum_result || '/' || morphometric_count
            ELSE NULL
        END
        WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;
    END IF;

    RETURN NEW;
END;
$$;
 A   DROP FUNCTION public.update_family_scorecard_morphometric_sum();
       public          postgres    false    6                       1255    110290    update_genus_remarks()    FUNCTION     -  CREATE FUNCTION public.update_genus_remarks() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Initialize genus_remarks variables
    DECLARE
        sample_master_text TEXT := 'Missing Values in the Sample Master: ';
        knowledge_base_text TEXT := 'Missing Values in the Knowledge Base: ';
        separator TEXT := '';
    BEGIN
        -- Check for missing values in public.fish_ratio columns
        IF (SELECT dorsal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NULL AND NEW.dorsal_count_score IS NOT NULL THEN
            sample_master_text := sample_master_text || 'Dorsal Count';
			separator := ', ';
        END IF;

        IF (SELECT anal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NULL AND NEW.anal_count_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Anal Count';
			separator := ', ';
        END IF;

        IF (SELECT pectoral_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NULL AND NEW.pectoral_count_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Pectoral Count';
			separator := ', ';
        END IF;

        IF (SELECT pelvic_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NULL AND NEW.pelvic_count_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Pelvic Count';
			separator := ', ';
        END IF;

        IF (SELECT caudal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NULL AND NEW.caudal_count_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Caudal Count';
			separator := ', ';
        END IF;

        IF (SELECT vertebrae_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NULL AND NEW.vertebrae_count_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Vertebrae Count';
			separator := ', ';
        END IF;

        -- Check for missing values in knowledge_base columns
		IF (NEW.dorsal_count_score IS NULL AND (SELECT dorsal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Dorsal Count';
		END IF;

		IF (NEW.anal_count_score IS NULL AND (SELECT anal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Anal Count';
		END IF;

		IF (NEW.pectoral_count_score IS NULL AND (SELECT pectoral_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Pectoral Count';
		END IF;

		IF (NEW.pelvic_count_score IS NULL AND (SELECT pelvic_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Pelvic Count';
		END IF;

		IF (NEW.caudal_count_score IS NULL AND (SELECT caudal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Caudal Count';
		END IF;

		IF (NEW.vertebrae_count_score IS NULL AND (SELECT dorsal_count FROM public.sample_master WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Vertebrae Count';
		END IF;

        -- Update morphometric_remarks column
		UPDATE public.genus_scorecard
        SET sample_remarks = CASE
                WHEN sample_master_text = 'Missing Values in the Sample Master: ' THEN 'Missing Values in the Sample Master: None'
                ELSE sample_master_text
            END,
            kbs_remarks = CASE
                WHEN knowledge_base_text = 'Missing Values in the Knowledge Base: ' THEN 'Missing Values in the Knowledge Base: None'
                ELSE knowledge_base_text
            END
        WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name;

        RETURN NEW;
    END;
    RETURN NULL;
END;
$$;
 -   DROP FUNCTION public.update_genus_remarks();
       public          postgres    false    6            *           1255    110645 %   update_genus_scorecard_meristic_sum()    FUNCTION     �  CREATE FUNCTION public.update_genus_scorecard_meristic_sum() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    meristic_sum_result NUMERIC;
    meristic_count INTEGER;
BEGIN
    meristic_sum_result := 0;
    meristic_count := 0;

    -- Check if the record exists in genus_scorecard
    IF EXISTS (
        SELECT 1
        FROM public.genus_scorecard
        WHERE sample_no = NEW.sample_no AND fgenus_name = NEW.fgenus_name
    ) THEN
        -- Calculate the sum of specified columns
        SELECT
            COALESCE(dorsal_count_score, 0) +
            COALESCE(anal_count_score, 0) +
            COALESCE(pectoral_count_score, 0) +
            COALESCE(caudal_count_score, 0) +
            COALESCE(vertebrae_count_score, 0) +
            COALESCE(pelvic_count_score, 0)
        INTO meristic_sum_result
        FROM public.genus_scorecard
        WHERE sample_no = NEW.sample_no AND fgenus_name = NEW.fgenus_name;

        -- Count the total number of non-null values
        SELECT
            (CASE WHEN dorsal_count_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN anal_count_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN pectoral_count_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN caudal_count_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN vertebrae_count_score IS NOT NULL THEN 1 ELSE 0 END) +
            (CASE WHEN pelvic_count_score IS NOT NULL THEN 1 ELSE 0 END)
        INTO meristic_count
        FROM public.genus_scorecard
        WHERE sample_no = NEW.sample_no AND fgenus_name = NEW.fgenus_name;

        -- Update the morphometric_sum column
        UPDATE public.genus_scorecard
        SET meristic_sum = CASE
            WHEN meristic_count > 0 THEN meristic_sum_result || '/' || meristic_count
            ELSE NULL
        END
        WHERE sample_no = NEW.sample_no AND fgenus_name = NEW.fgenus_name;
    END IF;

    RETURN NEW;
END;
$$;
 <   DROP FUNCTION public.update_genus_scorecard_meristic_sum();
       public          postgres    false    6                       1255    110291    update_group_decision()    FUNCTION     &�  CREATE FUNCTION public.update_group_decision() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CASE
        WHEN NEW.bd / NEW.bl < 0.10 THEN
            -- Group 1, 2, and 3
            CASE
				-- Group 1
                WHEN NEW.pal > 0.70 * NEW.bl THEN
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 1, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 2
				WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.pal >= 0.50 * NEW.bl AND NEW.pal <= 0.70 * NEW.bl AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 2, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 3
				WHEN NEW.pal < 0.50 * NEW.bl THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 3, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
                ELSE
                    RAISE NOTICE 'No matching conditions found for sample_no %', NEW.sample_no;
            END CASE;
        WHEN NEW.bd / NEW.bl >= 0.10 AND NEW.bd / NEW.bl <= 0.20 THEN
			-- Groups 4, 5, 6, 7, and 8
			CASE
				-- Group 4
				WHEN NEW.description = 'Gut Coiled and Compact Early' THEN
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 4, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 5
				WHEN NEW.description = 'Gut Coiled Early But Not Compact' THEN
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 5, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 6
				WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 6, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- GROUP 7
				WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled During or After Flexion' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 7, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- GROUP 8
				WHEN  NEW.description = 'Gut Initially Coiled: Gut Remains Uncoiled Until Hidden by Body Wall' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 8, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				ELSE
                    RAISE NOTICE 'No matching conditions found for sample_no %', NEW.sample_no;
            END CASE;
		WHEN NEW.bd / NEW.bl >= 0.20 AND NEW.bd / NEW.bl <= 0.40 THEN
			-- Groups 9, 10, 11, 12, and 13
			CASE
				-- Group 9
				WHEN NEW.description = 'Gut Coiled and Compact Early' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.description = 'Gut Coiled and Compact Early' AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 9, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 10
				WHEN NEW.description = 'Gut Coiled Early But Not Compact' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 10, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 11
				WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled Before Flexion' AND NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 11, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 12
				WHEN NEW.description = 'Gut Initially Coiled: Gut Coiled During or After Flexion' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 12, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 13
				WHEN NEW.description = 'Gut Initially Coiled: Gut Remains Uncoiled' THEN
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 13, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				ELSE
                    RAISE NOTICE 'No matching conditions found for sample_no %', NEW.sample_no;
            END CASE;
		WHEN NEW.bd / NEW.bl >= 0.40 AND NEW.bd / NEW.bl <= 0.70 THEN
			-- Groups 14, 15, 16, 17, and 18
			CASE
				-- Group 14
				WHEN NEW.description = 'Head and Trunk Very Broad' THEN
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 14, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 15
				WHEN NEW.description = 'Head and Trunk Strongly Compressed' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 15, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 16
				WHEN NEW.description = 'Head and Trunk Neither Broad Nor Strongly Compressed: Gut Coiled and Compact Early' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 16, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 17
				WHEN NEW.description = 'Head and Trunk Neither Broad Nor Strongly Compressed: Gut Coiled Early But Not Compact' THEN
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 17, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				-- Group 18
				WHEN NEW.description = 'Head and Trunk Neither Broad Nor Strongly Compressed: Gut Initially Uncoiled' THEN 
					CASE
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 18, 0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 1);
					END CASE;
				ELSE
                    RAISE NOTICE 'No matching conditions found for sample_no %', NEW.sample_no;
            END CASE;
		WHEN NEW.bd / NEW.bl > 0.70 THEN
			-- Group 19
			CASE
				WHEN NEW.description = 'Body Dorso-Ventrally Flattened' THEN 
					CASE 
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 1, 0, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl < 0.20 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 0, 1, 0, 1, 0, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 0, 1, 0, 0, 1, 0);
						WHEN NEW.hl / NEW.bl >= 0.20 AND NEW.hl / NEW.bl <= 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 0, 1, 0, 0, 0, 1);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl < 0.25 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 0, 0, 1, 1, 0, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl >= 0.25 AND NEW.ed / NEW.hl <= 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 0, 0, 1, 0, 1, 0);
						WHEN NEW.hl / NEW.bl > 0.33 AND NEW.ed / NEW.hl > 0.33 THEN
							INSERT INTO public.group_decision (sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye)
							VALUES (NEW.sample_no, 19, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 1);
					END CASE;
				ELSE
                    RAISE NOTICE 'No matching conditions found for sample_no %', NEW.sample_no;
            END CASE;
	END CASE;
	
	RETURN NEW;
END;
$$;
 .   DROP FUNCTION public.update_group_decision();
       public          postgres    false    6                       1255    110293    update_morphometric_remarks()    FUNCTION     
  CREATE FUNCTION public.update_morphometric_remarks() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Initialize morphometric_remarks variables
    DECLARE
        sample_master_text TEXT := 'Missing Values in the Sample Master: ';
        knowledge_base_text TEXT := 'Missing Values in the Knowledge Base: ';
        separator TEXT := '';
    BEGIN
        -- Check for missing values in public.fish_ratio columns
        IF (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.bd_score IS NOT NULL THEN
            sample_master_text := sample_master_text || 'Body Depth';
			separator := ', ';
        END IF;

        IF (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.pdl_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Predorsal-fin Length';
			separator := ', ';
        END IF;

        IF (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.hl_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Head Length';
			separator := ', ';
        END IF;

        IF (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.snl_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Snout Length';
			separator := ', ';
        END IF;

        IF (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.ed_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Eye Diameter';
			separator := ', ';
        END IF;

        IF (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.pal_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Preanal Length';
			separator := ', ';
        END IF;

        IF (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NULL AND NEW.vafl_score IS NOT NULL THEN
            sample_master_text := sample_master_text || separator || 'Vent to Anal-fin Length';
			separator := ', ';
        END IF;

        -- Check for missing values in knowledge_base columns
		IF (NEW.bd_score IS NULL AND (SELECT "BD/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Body Depth';
		END IF;

		IF (NEW.pdl_score IS NULL AND (SELECT "PDL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Predorsal-fin Length';
		END IF;

		IF (NEW.hl_score IS NULL AND (SELECT "HL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Head Length';
		END IF;

		IF (NEW.snl_score IS NULL AND (SELECT "SnL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Snout Length';
		END IF;

		IF (NEW.ed_score IS NULL AND (SELECT "ED/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Head Length';
		END IF;

		IF (NEW.pal_score IS NULL AND (SELECT "PAL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Preanal Length';
		END IF;

		IF (NEW.vafl_score IS NULL AND (SELECT "VAFL/BL_ratio" FROM public.fish_ratio WHERE sample_no = NEW.sample_no) IS NOT NULL) THEN
			IF knowledge_base_text != 'Missing Values in the Knowledge Base: ' THEN
				knowledge_base_text := knowledge_base_text || ', ';
			END IF;
			knowledge_base_text := knowledge_base_text || 'Vent to Anal-fin Length';
		END IF;

        -- Update morphometric_remarks column
		UPDATE public.family_scorecard
        SET sample_remarks = CASE
                WHEN sample_master_text = 'Missing Values in the Sample Master: ' THEN 'Missing Values in the Sample Master: None'
                ELSE sample_master_text
            END,
            kbs_remarks = CASE
                WHEN knowledge_base_text = 'Missing Values in the Knowledge Base: ' THEN 'Missing Values in the Knowledge Base: None'
                ELSE knowledge_base_text
            END
        WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;

        RETURN NEW;
    END;
    RETURN NULL;
END;
$$;
 4   DROP FUNCTION public.update_morphometric_remarks();
       public          postgres    false    6                        1255    110294 $   update_shape_characteristic_result()    FUNCTION     �  CREATE FUNCTION public.update_shape_characteristic_result() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update Very Elongate
    IF NEW.very_elongate = 1 THEN
        INSERT INTO public.shape_characteristic_result (sample_no, bd_characteristic, fgroup_no)
        VALUES (NEW.sample_no, 'Very Elongate', NEW.fgroup_no);
    END IF;

    -- Update Elongate
    IF NEW.elongate = 1 THEN
        INSERT INTO public.shape_characteristic_result (sample_no, bd_characteristic, fgroup_no)
        VALUES (NEW.sample_no, 'Elongate', NEW.fgroup_no);
    END IF;

    -- Update Moderate
    IF NEW.moderate = 1 THEN
        INSERT INTO public.shape_characteristic_result (sample_no, bd_characteristic, fgroup_no)
        VALUES (NEW.sample_no, 'Moderate', NEW.fgroup_no);
    END IF;

    -- Update Deep
    IF NEW.deep = 1 THEN
        INSERT INTO public.shape_characteristic_result (sample_no, bd_characteristic, fgroup_no)
        VALUES (NEW.sample_no, 'Deep', NEW.fgroup_no);
    END IF;

    -- Update Very Deep
    IF NEW.very_deep = 1 THEN
        INSERT INTO public.shape_characteristic_result (sample_no, bd_characteristic, fgroup_no)
        VALUES (NEW.sample_no, 'Very Deep', NEW.fgroup_no);
    END IF;

    RETURN NEW;
END;
$$;
 ;   DROP FUNCTION public.update_shape_characteristic_result();
       public          postgres    false    6            !           1255    110295 )   update_summary_ranking_meristic_remarks()    FUNCTION     O  CREATE FUNCTION public.update_summary_ranking_meristic_remarks() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update meristic_sample_remarks and meristic_kbs_remarks columns for genus_decision
    UPDATE public.summary_ranking
    SET
        meristic_sample_remarks = (
            SELECT sample_remarks
            FROM public.genus_scorecard
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name
        ),
        meristic_kbs_remarks = (
            SELECT kbs_remarks
            FROM public.genus_scorecard
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name
        )
    WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name;

    RETURN NEW;
END;

$$;
 @   DROP FUNCTION public.update_summary_ranking_meristic_remarks();
       public          postgres    false    6            "           1255    110296 -   update_summary_ranking_morphometric_remarks()    FUNCTION     �  CREATE FUNCTION public.update_summary_ranking_morphometric_remarks() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update meristic_sample_remarks and meristic_kbs_remarks columns for genus_decision
    UPDATE public.summary_ranking
    SET
        morphometric_sample_remarks = (
            SELECT sample_remarks
            FROM public.family_scorecard
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name
        ),
        morphometric_kbs_remarks = (
            SELECT kbs_remarks
            FROM public.family_scorecard
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name
        )
    WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;

    RETURN NEW;
END;

$$;
 D   DROP FUNCTION public.update_summary_ranking_morphometric_remarks();
       public          postgres    false    6            #           1255    110297     update_summary_ranking_remarks()    FUNCTION     �  CREATE FUNCTION public.update_summary_ranking_remarks() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Update meristic_sample_remarks and meristic_kbs_remarks columns for genus_decision
    UPDATE public.summary_ranking
    SET
        meristic_sample_remarks = (
            SELECT sample_remarks
            FROM public.genus_decision
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = OLD.fgenus_name
        ),
        meristic_kbs_remarks = (
            SELECT kbs_remarks
            FROM public.genus_decision
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = OLD.fgenus_name
        )
    WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name AND fgenus_name = OLD.fgenus_name;

    -- Update morphometric_sample_remarks and morphometric_kbs_remarks columns for morphometric_decision
    UPDATE public.summary_ranking
    SET
        morphometric_sample_remarks = (
            SELECT sample_remarks
            FROM public.morphometric_decision
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name
        ),
        morphometric_kbs_remarks = (
            SELECT kbs_remarks
            FROM public.morphometric_decision
            WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name
        )
    WHERE sample_no = NEW.sample_no AND ffamily_name = NEW.ffamily_name;

    RETURN NEW;
END;

$$;
 7   DROP FUNCTION public.update_summary_ranking_remarks();
       public          postgres    false    6            �            1259    110298    family_genus    TABLE     9  CREATE TABLE knowledge_base.family_genus (
    fgenus_name character varying(45) NOT NULL,
    ffamily_name character varying(45) NOT NULL,
    dorsal_range int4range,
    anal_range int4range,
    pectoral_range int4range,
    pelvic_range int4range,
    caudal_range int4range,
    vertebrae_range int4range
);
 (   DROP TABLE knowledge_base.family_genus;
       knowledge_base         heap    postgres    false    5            �            1259    110303    family_group    TABLE     �   CREATE TABLE knowledge_base.family_group (
    fgroup_no integer NOT NULL,
    ffamily_name character varying(45) NOT NULL,
    common_names character varying(200)
);
 (   DROP TABLE knowledge_base.family_group;
       knowledge_base         heap    postgres    false    5            �            1259    110306    ffamily_names    TABLE     �   CREATE TABLE knowledge_base.ffamily_names (
    ffamily_name character varying(45) NOT NULL,
    common_names character varying(200)
);
 )   DROP TABLE knowledge_base.ffamily_names;
       knowledge_base         heap    postgres    false    5            �            1259    110309 
   fish_group    TABLE     �   CREATE TABLE knowledge_base.fish_group (
    fgroup_no integer NOT NULL,
    "BD/BL_ratio" numrange,
    condition character varying(100),
    sub_condition character varying(100),
    "PAL/BL_ratio" numrange
);
 &   DROP TABLE knowledge_base.fish_group;
       knowledge_base         heap    postgres    false    5            �            1259    110314    flexion_stage    TABLE     K  CREATE TABLE knowledge_base.flexion_stage (
    ffamily_name character varying(45) NOT NULL,
    fgroup_no integer NOT NULL,
    stage_name character varying(50),
    bd_range numrange,
    ed_range numrange,
    hl_range numrange,
    pdl_range numrange,
    snl_range numrange,
    pal_range numrange,
    vafl_range numrange
);
 )   DROP TABLE knowledge_base.flexion_stage;
       knowledge_base         heap    postgres    false    5            �            1259    110319    postflexion_stage    TABLE     O  CREATE TABLE knowledge_base.postflexion_stage (
    ffamily_name character varying(45) NOT NULL,
    fgroup_no integer NOT NULL,
    stage_name character varying(50),
    bd_range numrange,
    ed_range numrange,
    hl_range numrange,
    pdl_range numrange,
    snl_range numrange,
    pal_range numrange,
    vafl_range numrange
);
 -   DROP TABLE knowledge_base.postflexion_stage;
       knowledge_base         heap    postgres    false    5            �            1259    110324    preflexion_stage    TABLE     N  CREATE TABLE knowledge_base.preflexion_stage (
    ffamily_name character varying(45) NOT NULL,
    fgroup_no integer NOT NULL,
    stage_name character varying(50),
    bd_range numrange,
    ed_range numrange,
    hl_range numrange,
    pdl_range numrange,
    snl_range numrange,
    pal_range numrange,
    vafl_range numrange
);
 ,   DROP TABLE knowledge_base.preflexion_stage;
       knowledge_base         heap    postgres    false    5            �            1259    110329    stages    TABLE     V   CREATE TABLE knowledge_base.stages (
    stage_name character varying(50) NOT NULL
);
 "   DROP TABLE knowledge_base.stages;
       knowledge_base         heap    postgres    false    5            �            1259    110143 
   auth_group    TABLE     f   CREATE TABLE public.auth_group (
    id integer NOT NULL,
    name character varying(150) NOT NULL
);
    DROP TABLE public.auth_group;
       public         heap    postgres    false    6            �            1259    110142    auth_group_id_seq    SEQUENCE     �   ALTER TABLE public.auth_group ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    6    223            �            1259    110151    auth_group_permissions    TABLE     �   CREATE TABLE public.auth_group_permissions (
    id bigint NOT NULL,
    group_id integer NOT NULL,
    permission_id integer NOT NULL
);
 *   DROP TABLE public.auth_group_permissions;
       public         heap    postgres    false    6            �            1259    110150    auth_group_permissions_id_seq    SEQUENCE     �   ALTER TABLE public.auth_group_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_group_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    225    6            �            1259    110137    auth_permission    TABLE     �   CREATE TABLE public.auth_permission (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    content_type_id integer NOT NULL,
    codename character varying(100) NOT NULL
);
 #   DROP TABLE public.auth_permission;
       public         heap    postgres    false    6            �            1259    110136    auth_permission_id_seq    SEQUENCE     �   ALTER TABLE public.auth_permission ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_permission_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    6    221            �            1259    110157 	   auth_user    TABLE     �  CREATE TABLE public.auth_user (
    id integer NOT NULL,
    password character varying(128) NOT NULL,
    last_login timestamp with time zone,
    is_superuser boolean NOT NULL,
    username character varying(150) NOT NULL,
    first_name character varying(150) NOT NULL,
    last_name character varying(150) NOT NULL,
    email character varying(254) NOT NULL,
    is_staff boolean NOT NULL,
    is_active boolean NOT NULL,
    date_joined timestamp with time zone NOT NULL
);
    DROP TABLE public.auth_user;
       public         heap    postgres    false    6            �            1259    110165    auth_user_groups    TABLE     ~   CREATE TABLE public.auth_user_groups (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    group_id integer NOT NULL
);
 $   DROP TABLE public.auth_user_groups;
       public         heap    postgres    false    6            �            1259    110164    auth_user_groups_id_seq    SEQUENCE     �   ALTER TABLE public.auth_user_groups ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_groups_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    6    229            �            1259    110156    auth_user_id_seq    SEQUENCE     �   ALTER TABLE public.auth_user ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    6    227            �            1259    110171    auth_user_user_permissions    TABLE     �   CREATE TABLE public.auth_user_user_permissions (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    permission_id integer NOT NULL
);
 .   DROP TABLE public.auth_user_user_permissions;
       public         heap    postgres    false    6            �            1259    110170 !   auth_user_user_permissions_id_seq    SEQUENCE     �   ALTER TABLE public.auth_user_user_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.auth_user_user_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    231    6            �            1259    110332    classification_result_id_seq    SEQUENCE     �   CREATE SEQUENCE public.classification_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.classification_result_id_seq;
       public          postgres    false    6            �            1259    110333    classification_result    TABLE     |  CREATE TABLE public.classification_result (
    classification_result_id integer DEFAULT nextval('public.classification_result_id_seq'::regclass) NOT NULL,
    sample_no integer,
    fgroup_no integer,
    ffamily_name character varying(45),
    fgenus_name character varying(45) DEFAULT NULL::character varying,
    rank integer,
    sample_timestamp timestamp with time zone
);
 )   DROP TABLE public.classification_result;
       public         heap    postgres    false    243    6            M           0    0    TABLE classification_result    ACL       GRANT SELECT,INSERT,UPDATE ON TABLE public.classification_result TO lab_examiner;
GRANT SELECT,DELETE,UPDATE ON TABLE public.classification_result TO research_assistant;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.classification_result TO study_leader;
          public          postgres    false    244            �            1259    110338 "   family_scorecard_fscorecard_no_seq    SEQUENCE     �   CREATE SEQUENCE public.family_scorecard_fscorecard_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.family_scorecard_fscorecard_no_seq;
       public          postgres    false    6            �            1259    110339    family_scorecard    TABLE     �  CREATE TABLE public.family_scorecard (
    fscorecard_no integer DEFAULT nextval('public.family_scorecard_fscorecard_no_seq'::regclass) NOT NULL,
    sample_no integer,
    ffamily_name character varying(45),
    bd_score smallint,
    ed_score smallint,
    hl_score smallint,
    pdl_score smallint,
    snl_score smallint,
    pal_score smallint,
    vafl_score smallint,
    sample_remarks character varying(150),
    kbs_remarks character varying(150),
    morphometric_sum character varying(10)
);
 $   DROP TABLE public.family_scorecard;
       public         heap    postgres    false    245    6            �            1259    110343 %   genus_scorecard_genusscorecard_no_seq    SEQUENCE     �   CREATE SEQUENCE public.genus_scorecard_genusscorecard_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.genus_scorecard_genusscorecard_no_seq;
       public          postgres    false    6            �            1259    110344    genus_scorecard    TABLE     n  CREATE TABLE public.genus_scorecard (
    genus_scorecard_no integer DEFAULT nextval('public.genus_scorecard_genusscorecard_no_seq'::regclass) NOT NULL,
    sample_no integer NOT NULL,
    ffamily_name character varying(45),
    fgenus_name character varying(45) DEFAULT NULL::character varying,
    dorsal_count_score smallint,
    anal_count_score smallint,
    pectoral_count_score smallint,
    caudal_count_score smallint,
    vertebrae_count_score smallint,
    pelvic_count_score smallint,
    sample_remarks character varying(150),
    kbs_remarks character varying(150),
    meristic_sum character varying(10)
);
 #   DROP TABLE public.genus_scorecard;
       public         heap    postgres    false    247    6            �            1259    110349    shape_characteristic_result_seq    SEQUENCE     �   CREATE SEQUENCE public.shape_characteristic_result_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.shape_characteristic_result_seq;
       public          postgres    false    6            �            1259    110350    shape_characteristic_result    TABLE     m  CREATE TABLE public.shape_characteristic_result (
    result_id integer DEFAULT COALESCE(nextval('public.shape_characteristic_result_seq'::regclass), (1)::bigint) NOT NULL,
    sample_no integer NOT NULL,
    fgroup_no integer,
    bd_characteristic character varying(20),
    hl_characteristic character varying(20),
    ed_characteristic character varying(20)
);
 /   DROP TABLE public.shape_characteristic_result;
       public         heap    postgres    false    249    6            N           0    0 !   TABLE shape_characteristic_result    ACL     �   GRANT SELECT,INSERT ON TABLE public.shape_characteristic_result TO lab_examiner;
GRANT SELECT,INSERT ON TABLE public.shape_characteristic_result TO research_assistant;
GRANT SELECT,INSERT ON TABLE public.shape_characteristic_result TO study_leader;
          public          postgres    false    250            �            1259    110354 &   summary_ranking_summary_ranking_no_seq    SEQUENCE     �   CREATE SEQUENCE public.summary_ranking_summary_ranking_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.summary_ranking_summary_ranking_no_seq;
       public          postgres    false    6            �            1259    110355    summary_ranking    TABLE     |  CREATE TABLE public.summary_ranking (
    summary_ranking_no integer DEFAULT nextval('public.summary_ranking_summary_ranking_no_seq'::regclass) NOT NULL,
    sample_no integer NOT NULL,
    ffamily_name character varying(45),
    fgenus_name character varying(45),
    meristic_sum character varying(10),
    morphometric_sum character varying(10),
    combined_scores numeric(10,5) DEFAULT NULL::numeric,
    meristic_sample_remarks character varying(150),
    meristic_kbs_remarks character varying(150),
    morphometric_sample_remarks character varying(150),
    morphometric_kbs_remarks character varying(150),
    rank integer
);
 #   DROP TABLE public.summary_ranking;
       public         heap    postgres    false    251    6            �            1259    110362 6   classification_and_characteristic_complete_result_view    VIEW     �  CREATE VIEW public.classification_and_characteristic_complete_result_view AS
 SELECT cr.classification_result_id,
    cr.sample_no,
    cr.fgroup_no,
    cr.ffamily_name,
    cr.fgenus_name,
    scr.bd_characteristic,
    scr.hl_characteristic,
    scr.ed_characteristic,
    gd.dorsal_count_score,
    gd.anal_count_score,
    gd.pectoral_count_score,
    gd.caudal_count_score,
    gd.vertebrae_count_score,
    gd.pelvic_count_score,
    ss.meristic_sum,
    md.bd_score,
    md.ed_score,
    md.hl_score,
    md.pdl_score,
    md.snl_score,
    md.pal_score,
    md.vafl_score,
    ss.morphometric_sum,
    cr.rank
   FROM ((((public.classification_result cr
     JOIN public.shape_characteristic_result scr ON ((cr.sample_no = scr.sample_no)))
     LEFT JOIN public.summary_ranking ss ON (((cr.sample_no = ss.sample_no) AND ((cr.ffamily_name)::text = (ss.ffamily_name)::text) AND ((cr.fgenus_name)::text = (ss.fgenus_name)::text))))
     LEFT JOIN public.genus_scorecard gd ON (((cr.sample_no = gd.sample_no) AND ((cr.ffamily_name)::text = (gd.ffamily_name)::text) AND ((cr.fgenus_name)::text = (gd.fgenus_name)::text))))
     LEFT JOIN public.family_scorecard md ON (((cr.sample_no = md.sample_no) AND ((cr.ffamily_name)::text = (md.ffamily_name)::text))));
 I   DROP VIEW public.classification_and_characteristic_complete_result_view;
       public          postgres    false    244    252    252    252    252    252    250    250    250    250    248    248    248    248    248    248    248    248    248    246    246    246    246    246    246    246    246    246    244    244    244    244    244    6            �            1259    110367 >   classification_and_characteristic_complete_result_with_remarks    VIEW     z  CREATE VIEW public.classification_and_characteristic_complete_result_with_remarks AS
 SELECT cr.classification_result_id,
    cr.sample_no,
    cr.fgroup_no,
    cr.ffamily_name,
    cr.fgenus_name,
    scr.bd_characteristic,
    scr.hl_characteristic,
    scr.ed_characteristic,
    gd.dorsal_count_score,
    gd.anal_count_score,
    gd.pectoral_count_score,
    gd.caudal_count_score,
    gd.vertebrae_count_score,
    gd.pelvic_count_score,
    ss.meristic_sum,
    ss.meristic_sample_remarks,
    ss.meristic_kbs_remarks,
    md.bd_score,
    md.ed_score,
    md.hl_score,
    md.pdl_score,
    md.snl_score,
    md.pal_score,
    md.vafl_score,
    ss.morphometric_sum,
    ss.morphometric_sample_remarks,
    ss.morphometric_kbs_remarks,
    cr.rank
   FROM ((((public.classification_result cr
     JOIN public.shape_characteristic_result scr ON ((cr.sample_no = scr.sample_no)))
     LEFT JOIN public.summary_ranking ss ON (((cr.sample_no = ss.sample_no) AND ((cr.ffamily_name)::text = (ss.ffamily_name)::text) AND ((cr.fgenus_name)::text = (ss.fgenus_name)::text))))
     LEFT JOIN public.genus_scorecard gd ON (((cr.sample_no = gd.sample_no) AND ((cr.ffamily_name)::text = (gd.ffamily_name)::text) AND ((cr.fgenus_name)::text = (gd.fgenus_name)::text))))
     LEFT JOIN public.family_scorecard md ON (((cr.sample_no = md.sample_no) AND ((cr.ffamily_name)::text = (md.ffamily_name)::text))));
 Q   DROP VIEW public.classification_and_characteristic_complete_result_with_remarks;
       public          postgres    false    252    252    252    252    252    252    252    252    252    250    250    250    250    248    248    244    244    244    244    244    244    246    246    246    246    246    246    246    246    246    248    248    248    248    248    248    248    6            �            1259    110372 -   classification_and_characteristic_result_view    VIEW       CREATE VIEW public.classification_and_characteristic_result_view AS
 SELECT cr.classification_result_id,
    cr.sample_no,
    cr.fgroup_no,
    cr.ffamily_name,
    cr.fgenus_name,
    scr.bd_characteristic,
    scr.hl_characteristic,
    scr.ed_characteristic,
    ss.meristic_sum,
    ss.morphometric_sum,
    cr.rank
   FROM ((public.classification_result cr
     JOIN public.shape_characteristic_result scr ON ((cr.sample_no = scr.sample_no)))
     LEFT JOIN public.summary_ranking ss ON (((cr.sample_no = ss.sample_no) AND ((cr.ffamily_name)::text = (ss.ffamily_name)::text) AND ((cr.fgenus_name)::text = (ss.fgenus_name)::text))));
 @   DROP VIEW public.classification_and_characteristic_result_view;
       public          postgres    false    252    244    244    244    244    244    250    250    250    250    252    252    252    252    244    6            �            1259    110229    django_admin_log    TABLE     �  CREATE TABLE public.django_admin_log (
    id integer NOT NULL,
    action_time timestamp with time zone NOT NULL,
    object_id text,
    object_repr character varying(200) NOT NULL,
    action_flag smallint NOT NULL,
    change_message text NOT NULL,
    content_type_id integer,
    user_id integer NOT NULL,
    CONSTRAINT django_admin_log_action_flag_check CHECK ((action_flag >= 0))
);
 $   DROP TABLE public.django_admin_log;
       public         heap    postgres    false    6            �            1259    110228    django_admin_log_id_seq    SEQUENCE     �   ALTER TABLE public.django_admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    233    6            �            1259    110129    django_content_type    TABLE     �   CREATE TABLE public.django_content_type (
    id integer NOT NULL,
    app_label character varying(100) NOT NULL,
    model character varying(100) NOT NULL
);
 '   DROP TABLE public.django_content_type;
       public         heap    postgres    false    6            �            1259    110128    django_content_type_id_seq    SEQUENCE     �   ALTER TABLE public.django_content_type ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_content_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    6    219            �            1259    110121    django_migrations    TABLE     �   CREATE TABLE public.django_migrations (
    id bigint NOT NULL,
    app character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    applied timestamp with time zone NOT NULL
);
 %   DROP TABLE public.django_migrations;
       public         heap    postgres    false    6            �            1259    110120    django_migrations_id_seq    SEQUENCE     �   ALTER TABLE public.django_migrations ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.django_migrations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);
            public          postgres    false    6    217            �            1259    110263    django_session    TABLE     �   CREATE TABLE public.django_session (
    session_key character varying(40) NOT NULL,
    session_data text NOT NULL,
    expire_date timestamp with time zone NOT NULL
);
 "   DROP TABLE public.django_session;
       public         heap    postgres    false    6                        1259    110377 
   fish_ratio    TABLE     �  CREATE TABLE public.fish_ratio (
    sample_no integer NOT NULL,
    "BD/BL_ratio" numeric(10,2) DEFAULT NULL::numeric,
    "PDL/BL_ratio" numeric(10,2) DEFAULT NULL::numeric,
    "HL/BL_ratio" numeric(10,2) DEFAULT NULL::numeric,
    "SnL/BL_ratio" numeric(10,2) DEFAULT NULL::numeric,
    "ED/BL_ratio" numeric(10,2) DEFAULT NULL::numeric,
    "PAL/BL_ratio" numeric(10,2) DEFAULT NULL::numeric,
    "VAFL/BL_ratio" numeric(10,2) DEFAULT NULL::numeric
);
    DROP TABLE public.fish_ratio;
       public         heap    postgres    false    6            O           0    0    TABLE fish_ratio    ACL     �   GRANT SELECT,INSERT ON TABLE public.fish_ratio TO research_assistant;
GRANT SELECT,INSERT,UPDATE ON TABLE public.fish_ratio TO lab_examiner;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.fish_ratio TO study_leader;
          public          postgres    false    256                       1259    110387 !   group_scorecard_gscorecard_no_seq    SEQUENCE     �   CREATE SEQUENCE public.group_scorecard_gscorecard_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.group_scorecard_gscorecard_no_seq;
       public          postgres    false    6                       1259    110388    group_decision    TABLE     �  CREATE TABLE public.group_decision (
    gdecision_no integer DEFAULT nextval('public.group_scorecard_gscorecard_no_seq'::regclass) NOT NULL,
    sample_no integer NOT NULL,
    fgroup_no integer,
    very_elongate smallint,
    elongate smallint,
    moderate smallint,
    deep smallint,
    very_deep smallint,
    small_head smallint,
    moderate_head smallint,
    large_head smallint,
    small_eye smallint,
    moderate_eye smallint,
    large_eye smallint
);
 "   DROP TABLE public.group_decision;
       public         heap    postgres    false    257    6                       1259    110392    sample_no_seq    SEQUENCE     v   CREATE SEQUENCE public.sample_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.sample_no_seq;
       public          postgres    false    6                       1259    110393    sample_master    TABLE     �  CREATE TABLE public.sample_master (
    sample_no integer DEFAULT nextval('public.sample_no_seq'::regclass) NOT NULL,
    assessor_name character varying(50) NOT NULL,
    date_collected date NOT NULL,
    date_measured date NOT NULL,
    location_code character varying(10) NOT NULL,
    plankton_net_type character varying(20) DEFAULT NULL::character varying,
    bl numeric(10,2) DEFAULT NULL::numeric,
    pdl numeric(10,2) DEFAULT NULL::numeric,
    hl numeric(10,2) DEFAULT NULL::numeric,
    snl numeric(10,2) DEFAULT NULL::numeric,
    ed numeric(10,2) DEFAULT NULL::numeric,
    bd numeric(10,2) DEFAULT NULL::numeric,
    pal numeric(10,2) DEFAULT NULL::numeric,
    vafl numeric(10,2) DEFAULT NULL::numeric,
    dorsal_count integer,
    anal_count integer,
    pectoral_count integer,
    pelvic_count integer,
    caudal_count integer,
    vertebrae_count integer,
    stage_name character varying(50),
    margin_no numeric(10,2),
    description character varying(100)
);
 !   DROP TABLE public.sample_master;
       public         heap    postgres    false    259    6            P           0    0    TABLE sample_master    ACL     �   GRANT SELECT,INSERT,UPDATE ON TABLE public.sample_master TO research_assistant;
GRANT SELECT,INSERT ON TABLE public.sample_master TO lab_examiner;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sample_master TO study_leader;
          public          postgres    false    260                       1259    110406    sample_view    VIEW     6  CREATE VIEW public.sample_view AS
 SELECT sample_no,
    stage_name,
    bl,
    pdl,
    hl,
    snl,
    ed,
    bd,
    pal,
    vafl,
    dorsal_count,
    anal_count,
    pectoral_count,
    pelvic_count,
    caudal_count,
    vertebrae_count,
    margin_no,
    description
   FROM public.sample_master;
    DROP VIEW public.sample_view;
       public          postgres    false    260    260    260    260    260    260    260    260    260    260    260    260    260    260    260    260    260    260    6            *          0    110298    family_genus 
   TABLE DATA           �   COPY knowledge_base.family_genus (fgenus_name, ffamily_name, dorsal_range, anal_range, pectoral_range, pelvic_range, caudal_range, vertebrae_range) FROM stdin;
    knowledge_base          postgres    false    235   ��      +          0    110303    family_group 
   TABLE DATA           U   COPY knowledge_base.family_group (fgroup_no, ffamily_name, common_names) FROM stdin;
    knowledge_base          postgres    false    236    9      ,          0    110306    ffamily_names 
   TABLE DATA           K   COPY knowledge_base.ffamily_names (ffamily_name, common_names) FROM stdin;
    knowledge_base          postgres    false    237   �C      -          0    110309 
   fish_group 
   TABLE DATA           p   COPY knowledge_base.fish_group (fgroup_no, "BD/BL_ratio", condition, sub_condition, "PAL/BL_ratio") FROM stdin;
    knowledge_base          postgres    false    238   FL      .          0    110314    flexion_stage 
   TABLE DATA           �   COPY knowledge_base.flexion_stage (ffamily_name, fgroup_no, stage_name, bd_range, ed_range, hl_range, pdl_range, snl_range, pal_range, vafl_range) FROM stdin;
    knowledge_base          postgres    false    239   �M      /          0    110319    postflexion_stage 
   TABLE DATA           �   COPY knowledge_base.postflexion_stage (ffamily_name, fgroup_no, stage_name, bd_range, ed_range, hl_range, pdl_range, snl_range, pal_range, vafl_range) FROM stdin;
    knowledge_base          postgres    false    240   ,`      0          0    110324    preflexion_stage 
   TABLE DATA           �   COPY knowledge_base.preflexion_stage (ffamily_name, fgroup_no, stage_name, bd_range, ed_range, hl_range, pdl_range, snl_range, pal_range, vafl_range) FROM stdin;
    knowledge_base          postgres    false    241   �r      1          0    110329    stages 
   TABLE DATA           4   COPY knowledge_base.stages (stage_name) FROM stdin;
    knowledge_base          postgres    false    242   ��                0    110143 
   auth_group 
   TABLE DATA           .   COPY public.auth_group (id, name) FROM stdin;
    public          postgres    false    223   �                 0    110151    auth_group_permissions 
   TABLE DATA           M   COPY public.auth_group_permissions (id, group_id, permission_id) FROM stdin;
    public          postgres    false    225   �                0    110137    auth_permission 
   TABLE DATA           N   COPY public.auth_permission (id, name, content_type_id, codename) FROM stdin;
    public          postgres    false    221   �      "          0    110157 	   auth_user 
   TABLE DATA           �   COPY public.auth_user (id, password, last_login, is_superuser, username, first_name, last_name, email, is_staff, is_active, date_joined) FROM stdin;
    public          postgres    false    227   ��      $          0    110165    auth_user_groups 
   TABLE DATA           A   COPY public.auth_user_groups (id, user_id, group_id) FROM stdin;
    public          postgres    false    229   G�      &          0    110171    auth_user_user_permissions 
   TABLE DATA           P   COPY public.auth_user_user_permissions (id, user_id, permission_id) FROM stdin;
    public          postgres    false    231   d�      3          0    110333    classification_result 
   TABLE DATA           �   COPY public.classification_result (classification_result_id, sample_no, fgroup_no, ffamily_name, fgenus_name, rank, sample_timestamp) FROM stdin;
    public          postgres    false    244   ��      (          0    110229    django_admin_log 
   TABLE DATA           �   COPY public.django_admin_log (id, action_time, object_id, object_repr, action_flag, change_message, content_type_id, user_id) FROM stdin;
    public          postgres    false    233   �                0    110129    django_content_type 
   TABLE DATA           C   COPY public.django_content_type (id, app_label, model) FROM stdin;
    public          postgres    false    219   #�                0    110121    django_migrations 
   TABLE DATA           C   COPY public.django_migrations (id, app, name, applied) FROM stdin;
    public          postgres    false    217   ޏ      )          0    110263    django_session 
   TABLE DATA           P   COPY public.django_session (session_key, session_data, expire_date) FROM stdin;
    public          postgres    false    234   =�      5          0    110339    family_scorecard 
   TABLE DATA           �   COPY public.family_scorecard (fscorecard_no, sample_no, ffamily_name, bd_score, ed_score, hl_score, pdl_score, snl_score, pal_score, vafl_score, sample_remarks, kbs_remarks, morphometric_sum) FROM stdin;
    public          postgres    false    246   W�      <          0    110377 
   fish_ratio 
   TABLE DATA           �   COPY public.fish_ratio (sample_no, "BD/BL_ratio", "PDL/BL_ratio", "HL/BL_ratio", "SnL/BL_ratio", "ED/BL_ratio", "PAL/BL_ratio", "VAFL/BL_ratio") FROM stdin;
    public          postgres    false    256   ϙ      7          0    110344    genus_scorecard 
   TABLE DATA           	  COPY public.genus_scorecard (genus_scorecard_no, sample_no, ffamily_name, fgenus_name, dorsal_count_score, anal_count_score, pectoral_count_score, caudal_count_score, vertebrae_count_score, pelvic_count_score, sample_remarks, kbs_remarks, meristic_sum) FROM stdin;
    public          postgres    false    248   Y�      >          0    110388    group_decision 
   TABLE DATA           �   COPY public.group_decision (gdecision_no, sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye) FROM stdin;
    public          postgres    false    258   7�      @          0    110393    sample_master 
   TABLE DATA           "  COPY public.sample_master (sample_no, assessor_name, date_collected, date_measured, location_code, plankton_net_type, bl, pdl, hl, snl, ed, bd, pal, vafl, dorsal_count, anal_count, pectoral_count, pelvic_count, caudal_count, vertebrae_count, stage_name, margin_no, description) FROM stdin;
    public          postgres    false    260   ��      9          0    110350    shape_characteristic_result 
   TABLE DATA           �   COPY public.shape_characteristic_result (result_id, sample_no, fgroup_no, bd_characteristic, hl_characteristic, ed_characteristic) FROM stdin;
    public          postgres    false    250   x�      ;          0    110355    summary_ranking 
   TABLE DATA              COPY public.summary_ranking (summary_ranking_no, sample_no, ffamily_name, fgenus_name, meristic_sum, morphometric_sum, combined_scores, meristic_sample_remarks, meristic_kbs_remarks, morphometric_sample_remarks, morphometric_kbs_remarks, rank) FROM stdin;
    public          postgres    false    252   �      Q           0    0    auth_group_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.auth_group_id_seq', 1, false);
          public          postgres    false    222            R           0    0    auth_group_permissions_id_seq    SEQUENCE SET     L   SELECT pg_catalog.setval('public.auth_group_permissions_id_seq', 1, false);
          public          postgres    false    224            S           0    0    auth_permission_id_seq    SEQUENCE SET     E   SELECT pg_catalog.setval('public.auth_permission_id_seq', 52, true);
          public          postgres    false    220            T           0    0    auth_user_groups_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.auth_user_groups_id_seq', 1, false);
          public          postgres    false    228            U           0    0    auth_user_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.auth_user_id_seq', 1, true);
          public          postgres    false    226            V           0    0 !   auth_user_user_permissions_id_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.auth_user_user_permissions_id_seq', 1, false);
          public          postgres    false    230            W           0    0    classification_result_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.classification_result_id_seq', 18608, true);
          public          postgres    false    243            X           0    0    django_admin_log_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.django_admin_log_id_seq', 1, false);
          public          postgres    false    232            Y           0    0    django_content_type_id_seq    SEQUENCE SET     I   SELECT pg_catalog.setval('public.django_content_type_id_seq', 13, true);
          public          postgres    false    218            Z           0    0    django_migrations_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.django_migrations_id_seq', 25, true);
          public          postgres    false    216            [           0    0 "   family_scorecard_fscorecard_no_seq    SEQUENCE SET     S   SELECT pg_catalog.setval('public.family_scorecard_fscorecard_no_seq', 3440, true);
          public          postgres    false    245            \           0    0 %   genus_scorecard_genusscorecard_no_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.genus_scorecard_genusscorecard_no_seq', 18076, true);
          public          postgres    false    247            ]           0    0 !   group_scorecard_gscorecard_no_seq    SEQUENCE SET     Q   SELECT pg_catalog.setval('public.group_scorecard_gscorecard_no_seq', 235, true);
          public          postgres    false    257            ^           0    0    sample_no_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.sample_no_seq', 158, true);
          public          postgres    false    259            _           0    0    shape_characteristic_result_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.shape_characteristic_result_seq', 920, true);
          public          postgres    false    249            `           0    0 &   summary_ranking_summary_ranking_no_seq    SEQUENCE SET     W   SELECT pg_catalog.setval('public.summary_ranking_summary_ranking_no_seq', 3568, true);
          public          postgres    false    251            9           2606    110411    family_genus family_genus_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY knowledge_base.family_genus
    ADD CONSTRAINT family_genus_pkey PRIMARY KEY (fgenus_name);
 P   ALTER TABLE ONLY knowledge_base.family_genus DROP CONSTRAINT family_genus_pkey;
       knowledge_base            postgres    false    235            ;           2606    110413 ,   family_group ffamily_name_and_fgroup_no_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_group
    ADD CONSTRAINT ffamily_name_and_fgroup_no_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 ^   ALTER TABLE ONLY knowledge_base.family_group DROP CONSTRAINT ffamily_name_and_fgroup_no_pkey;
       knowledge_base            postgres    false    236    236            A           2606    110415 1   flexion_stage ffamily_name_fgroup_no_flexion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.flexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_flexion_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 c   ALTER TABLE ONLY knowledge_base.flexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_flexion_pkey;
       knowledge_base            postgres    false    239    239            C           2606    110417 9   postflexion_stage ffamily_name_fgroup_no_postflexion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.postflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_postflexion_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 k   ALTER TABLE ONLY knowledge_base.postflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_postflexion_pkey;
       knowledge_base            postgres    false    240    240            E           2606    110419 7   preflexion_stage ffamily_name_fgroup_no_preflexion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.preflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_preflexion_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 i   ALTER TABLE ONLY knowledge_base.preflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_preflexion_pkey;
       knowledge_base            postgres    false    241    241            =           2606    110421 -   ffamily_names ffamily_names_ffamily_name_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY knowledge_base.ffamily_names
    ADD CONSTRAINT ffamily_names_ffamily_name_pkey PRIMARY KEY (ffamily_name);
 _   ALTER TABLE ONLY knowledge_base.ffamily_names DROP CONSTRAINT ffamily_names_ffamily_name_pkey;
       knowledge_base            postgres    false    237            ?           2606    110423    fish_group fish_group_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY knowledge_base.fish_group
    ADD CONSTRAINT fish_group_pkey PRIMARY KEY (fgroup_no);
 L   ALTER TABLE ONLY knowledge_base.fish_group DROP CONSTRAINT fish_group_pkey;
       knowledge_base            postgres    false    238            G           2606    110425    stages stages_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY knowledge_base.stages
    ADD CONSTRAINT stages_pkey PRIMARY KEY (stage_name);
 D   ALTER TABLE ONLY knowledge_base.stages DROP CONSTRAINT stages_pkey;
       knowledge_base            postgres    false    242                       2606    110261    auth_group auth_group_name_key 
   CONSTRAINT     Y   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_name_key UNIQUE (name);
 H   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_name_key;
       public            postgres    false    223                       2606    110186 R   auth_group_permissions auth_group_permissions_group_id_permission_id_0cd325b0_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq UNIQUE (group_id, permission_id);
 |   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_permission_id_0cd325b0_uniq;
       public            postgres    false    225    225                       2606    110155 2   auth_group_permissions auth_group_permissions_pkey 
   CONSTRAINT     p   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_pkey PRIMARY KEY (id);
 \   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_pkey;
       public            postgres    false    225                       2606    110147    auth_group auth_group_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.auth_group
    ADD CONSTRAINT auth_group_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.auth_group DROP CONSTRAINT auth_group_pkey;
       public            postgres    false    223                       2606    110177 F   auth_permission auth_permission_content_type_id_codename_01ab375a_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq UNIQUE (content_type_id, codename);
 p   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_codename_01ab375a_uniq;
       public            postgres    false    221    221                       2606    110141 $   auth_permission auth_permission_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_pkey;
       public            postgres    false    221            &           2606    110169 &   auth_user_groups auth_user_groups_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_pkey;
       public            postgres    false    229            )           2606    110201 @   auth_user_groups auth_user_groups_user_id_group_id_94350c0c_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq UNIQUE (user_id, group_id);
 j   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_user_id_group_id_94350c0c_uniq;
       public            postgres    false    229    229                        2606    110161    auth_user auth_user_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.auth_user DROP CONSTRAINT auth_user_pkey;
       public            postgres    false    227            ,           2606    110175 :   auth_user_user_permissions auth_user_user_permissions_pkey 
   CONSTRAINT     x   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_pkey PRIMARY KEY (id);
 d   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permissions_pkey;
       public            postgres    false    231            /           2606    110215 Y   auth_user_user_permissions auth_user_user_permissions_user_id_permission_id_14a6b632_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq UNIQUE (user_id, permission_id);
 �   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permissions_user_id_permission_id_14a6b632_uniq;
       public            postgres    false    231    231            #           2606    110256     auth_user auth_user_username_key 
   CONSTRAINT     _   ALTER TABLE ONLY public.auth_user
    ADD CONSTRAINT auth_user_username_key UNIQUE (username);
 J   ALTER TABLE ONLY public.auth_user DROP CONSTRAINT auth_user_username_key;
       public            postgres    false    227            I           2606    110427 0   classification_result classification_result_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.classification_result
    ADD CONSTRAINT classification_result_pkey PRIMARY KEY (classification_result_id);
 Z   ALTER TABLE ONLY public.classification_result DROP CONSTRAINT classification_result_pkey;
       public            postgres    false    244            2           2606    110236 &   django_admin_log django_admin_log_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_pkey;
       public            postgres    false    233                       2606    110135 E   django_content_type django_content_type_app_label_model_76bd3d3b_uniq 
   CONSTRAINT     �   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq UNIQUE (app_label, model);
 o   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_app_label_model_76bd3d3b_uniq;
       public            postgres    false    219    219                       2606    110133 ,   django_content_type django_content_type_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.django_content_type
    ADD CONSTRAINT django_content_type_pkey PRIMARY KEY (id);
 V   ALTER TABLE ONLY public.django_content_type DROP CONSTRAINT django_content_type_pkey;
       public            postgres    false    219            
           2606    110127 (   django_migrations django_migrations_pkey 
   CONSTRAINT     f   ALTER TABLE ONLY public.django_migrations
    ADD CONSTRAINT django_migrations_pkey PRIMARY KEY (id);
 R   ALTER TABLE ONLY public.django_migrations DROP CONSTRAINT django_migrations_pkey;
       public            postgres    false    217            6           2606    110269 "   django_session django_session_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.django_session
    ADD CONSTRAINT django_session_pkey PRIMARY KEY (session_key);
 L   ALTER TABLE ONLY public.django_session DROP CONSTRAINT django_session_pkey;
       public            postgres    false    234            K           2606    110429 &   family_scorecard family_scorecard_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.family_scorecard
    ADD CONSTRAINT family_scorecard_pkey PRIMARY KEY (fscorecard_no);
 P   ALTER TABLE ONLY public.family_scorecard DROP CONSTRAINT family_scorecard_pkey;
       public            postgres    false    246            S           2606    110431    fish_ratio fish_ratio_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.fish_ratio
    ADD CONSTRAINT fish_ratio_pkey PRIMARY KEY (sample_no);
 D   ALTER TABLE ONLY public.fish_ratio DROP CONSTRAINT fish_ratio_pkey;
       public            postgres    false    256            M           2606    110433 $   genus_scorecard genus_scorecard_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.genus_scorecard
    ADD CONSTRAINT genus_scorecard_pkey PRIMARY KEY (genus_scorecard_no);
 N   ALTER TABLE ONLY public.genus_scorecard DROP CONSTRAINT genus_scorecard_pkey;
       public            postgres    false    248            U           2606    110435 #   group_decision group_scorecard_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.group_decision
    ADD CONSTRAINT group_scorecard_pkey PRIMARY KEY (gdecision_no);
 M   ALTER TABLE ONLY public.group_decision DROP CONSTRAINT group_scorecard_pkey;
       public            postgres    false    258            W           2606    110437     sample_master sample_master_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.sample_master
    ADD CONSTRAINT sample_master_pkey PRIMARY KEY (sample_no);
 J   ALTER TABLE ONLY public.sample_master DROP CONSTRAINT sample_master_pkey;
       public            postgres    false    260            O           2606    110439 <   shape_characteristic_result shape_characteristic_result_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.shape_characteristic_result
    ADD CONSTRAINT shape_characteristic_result_pkey PRIMARY KEY (result_id);
 f   ALTER TABLE ONLY public.shape_characteristic_result DROP CONSTRAINT shape_characteristic_result_pkey;
       public            postgres    false    250            Q           2606    110441    summary_ranking summary_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.summary_ranking
    ADD CONSTRAINT summary_pkey PRIMARY KEY (summary_ranking_no);
 F   ALTER TABLE ONLY public.summary_ranking DROP CONSTRAINT summary_pkey;
       public            postgres    false    252                       1259    110262    auth_group_name_a6ea08ec_like    INDEX     h   CREATE INDEX auth_group_name_a6ea08ec_like ON public.auth_group USING btree (name varchar_pattern_ops);
 1   DROP INDEX public.auth_group_name_a6ea08ec_like;
       public            postgres    false    223                       1259    110197 (   auth_group_permissions_group_id_b120cbf9    INDEX     o   CREATE INDEX auth_group_permissions_group_id_b120cbf9 ON public.auth_group_permissions USING btree (group_id);
 <   DROP INDEX public.auth_group_permissions_group_id_b120cbf9;
       public            postgres    false    225                       1259    110198 -   auth_group_permissions_permission_id_84c5c92e    INDEX     y   CREATE INDEX auth_group_permissions_permission_id_84c5c92e ON public.auth_group_permissions USING btree (permission_id);
 A   DROP INDEX public.auth_group_permissions_permission_id_84c5c92e;
       public            postgres    false    225                       1259    110183 (   auth_permission_content_type_id_2f476e4b    INDEX     o   CREATE INDEX auth_permission_content_type_id_2f476e4b ON public.auth_permission USING btree (content_type_id);
 <   DROP INDEX public.auth_permission_content_type_id_2f476e4b;
       public            postgres    false    221            $           1259    110213 "   auth_user_groups_group_id_97559544    INDEX     c   CREATE INDEX auth_user_groups_group_id_97559544 ON public.auth_user_groups USING btree (group_id);
 6   DROP INDEX public.auth_user_groups_group_id_97559544;
       public            postgres    false    229            '           1259    110212 !   auth_user_groups_user_id_6a12ed8b    INDEX     a   CREATE INDEX auth_user_groups_user_id_6a12ed8b ON public.auth_user_groups USING btree (user_id);
 5   DROP INDEX public.auth_user_groups_user_id_6a12ed8b;
       public            postgres    false    229            *           1259    110227 1   auth_user_user_permissions_permission_id_1fbb5f2c    INDEX     �   CREATE INDEX auth_user_user_permissions_permission_id_1fbb5f2c ON public.auth_user_user_permissions USING btree (permission_id);
 E   DROP INDEX public.auth_user_user_permissions_permission_id_1fbb5f2c;
       public            postgres    false    231            -           1259    110226 +   auth_user_user_permissions_user_id_a95ead1b    INDEX     u   CREATE INDEX auth_user_user_permissions_user_id_a95ead1b ON public.auth_user_user_permissions USING btree (user_id);
 ?   DROP INDEX public.auth_user_user_permissions_user_id_a95ead1b;
       public            postgres    false    231            !           1259    110257     auth_user_username_6821ab7c_like    INDEX     n   CREATE INDEX auth_user_username_6821ab7c_like ON public.auth_user USING btree (username varchar_pattern_ops);
 4   DROP INDEX public.auth_user_username_6821ab7c_like;
       public            postgres    false    227            0           1259    110247 )   django_admin_log_content_type_id_c4bce8eb    INDEX     q   CREATE INDEX django_admin_log_content_type_id_c4bce8eb ON public.django_admin_log USING btree (content_type_id);
 =   DROP INDEX public.django_admin_log_content_type_id_c4bce8eb;
       public            postgres    false    233            3           1259    110248 !   django_admin_log_user_id_c564eba6    INDEX     a   CREATE INDEX django_admin_log_user_id_c564eba6 ON public.django_admin_log USING btree (user_id);
 5   DROP INDEX public.django_admin_log_user_id_c564eba6;
       public            postgres    false    233            4           1259    110271 #   django_session_expire_date_a5c62663    INDEX     e   CREATE INDEX django_session_expire_date_a5c62663 ON public.django_session USING btree (expire_date);
 7   DROP INDEX public.django_session_expire_date_a5c62663;
       public            postgres    false    234            7           1259    110270 (   django_session_session_key_c0390e0f_like    INDEX     ~   CREATE INDEX django_session_session_key_c0390e0f_like ON public.django_session USING btree (session_key varchar_pattern_ops);
 <   DROP INDEX public.django_session_session_key_c0390e0f_like;
       public            postgres    false    234            �           2620    110442 "   sample_master calculate_fish_ratio    TRIGGER     �   CREATE TRIGGER calculate_fish_ratio AFTER INSERT ON public.sample_master FOR EACH ROW EXECUTE FUNCTION public.sample_master_fish_ratio();
 ;   DROP TRIGGER calculate_fish_ratio ON public.sample_master;
       public          postgres    false    260    293            x           2620    110443 .   genus_scorecard insert_summary_ranking_trigger    TRIGGER     �   CREATE TRIGGER insert_summary_ranking_trigger AFTER INSERT ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.insert_summary_ranking();
 G   DROP TRIGGER insert_summary_ranking_trigger ON public.genus_scorecard;
       public          postgres    false    295    248            |           2620    110444 1   summary_ranking trig_insert_classification_result    TRIGGER     �   CREATE TRIGGER trig_insert_classification_result AFTER INSERT ON public.summary_ranking FOR EACH ROW EXECUTE FUNCTION public.insert_to_classification_result();
 J   DROP TRIGGER trig_insert_classification_result ON public.summary_ranking;
       public          postgres    false    252    283            ~           2620    110445 3   group_decision trig_insert_flexion_family_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_flexion_family_scorecard AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_flexion_family_scorecard_function();
 L   DROP TRIGGER trig_insert_flexion_family_scorecard ON public.group_decision;
       public          postgres    false    265    258            t           2620    110446 ,   family_scorecard trig_insert_genus_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_genus_scorecard AFTER INSERT ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.insert_genus_scorecard();
 E   DROP TRIGGER trig_insert_genus_scorecard ON public.family_scorecard;
       public          postgres    false    266    246                       2620    110447 7   group_decision trig_insert_postflexion_family_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_postflexion_family_scorecard AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_postflexion_family_scorecard_function();
 P   DROP TRIGGER trig_insert_postflexion_family_scorecard ON public.group_decision;
       public          postgres    false    258    269            �           2620    110448 6   group_decision trig_insert_preflexion_family_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_preflexion_family_scorecard AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_preflexion_family_scorecard_function();
 O   DROP TRIGGER trig_insert_preflexion_family_scorecard ON public.group_decision;
       public          postgres    false    280    258            �           2620    110449 6   group_decision trig_insert_shape_characteristic_result    TRIGGER     �   CREATE TRIGGER trig_insert_shape_characteristic_result AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_shape_characteristic_result();
 O   DROP TRIGGER trig_insert_shape_characteristic_result ON public.group_decision;
       public          postgres    false    258    282            }           2620    110450 1   summary_ranking trig_update_classification_result    TRIGGER     �   CREATE TRIGGER trig_update_classification_result AFTER UPDATE ON public.summary_ranking FOR EACH ROW EXECUTE FUNCTION public.update_classification_result();
 J   DROP TRIGGER trig_update_classification_result ON public.summary_ranking;
       public          postgres    false    267    252            �           2620    110451 +   sample_master trigger_update_group_decision    TRIGGER     �   CREATE TRIGGER trigger_update_group_decision AFTER INSERT ON public.sample_master FOR EACH ROW EXECUTE FUNCTION public.update_group_decision();
 D   DROP TRIGGER trigger_update_group_decision ON public.sample_master;
       public          postgres    false    260    286            u           2620    110638 A   family_scorecard update_family_scorecard_morphometric_sum_trigger    TRIGGER     �   CREATE TRIGGER update_family_scorecard_morphometric_sum_trigger AFTER INSERT ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_family_scorecard_morphometric_sum();
 Z   DROP TRIGGER update_family_scorecard_morphometric_sum_trigger ON public.family_scorecard;
       public          postgres    false    246    297            y           2620    110452 ,   genus_scorecard update_genus_remarks_trigger    TRIGGER     �   CREATE TRIGGER update_genus_remarks_trigger AFTER INSERT ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_genus_remarks();
 E   DROP TRIGGER update_genus_remarks_trigger ON public.genus_scorecard;
       public          postgres    false    285    248            z           2620    110646 ;   genus_scorecard update_genus_scorecard_meristic_sum_trigger    TRIGGER     �   CREATE TRIGGER update_genus_scorecard_meristic_sum_trigger AFTER INSERT ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_genus_scorecard_meristic_sum();
 T   DROP TRIGGER update_genus_scorecard_meristic_sum_trigger ON public.genus_scorecard;
       public          postgres    false    248    298            v           2620    110453 4   family_scorecard update_morphometric_remarks_trigger    TRIGGER     �   CREATE TRIGGER update_morphometric_remarks_trigger AFTER INSERT ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_morphometric_remarks();
 M   DROP TRIGGER update_morphometric_remarks_trigger ON public.family_scorecard;
       public          postgres    false    246    287            w           2620    110454 N   family_scorecard update_morphometric_summary_ranking_morphometric_remarks_trig    TRIGGER     �   CREATE TRIGGER update_morphometric_summary_ranking_morphometric_remarks_trig AFTER UPDATE ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_summary_ranking_morphometric_remarks();
 g   DROP TRIGGER update_morphometric_summary_ranking_morphometric_remarks_trig ON public.family_scorecard;
       public          postgres    false    246    290            {           2620    110455 A   genus_scorecard update_summary_scorecard_meristic_remarks_trigger    TRIGGER     �   CREATE TRIGGER update_summary_scorecard_meristic_remarks_trigger AFTER UPDATE ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_summary_ranking_meristic_remarks();
 Z   DROP TRIGGER update_summary_scorecard_meristic_remarks_trigger ON public.genus_scorecard;
       public          postgres    false    289    248            a           2606    110456 )   family_genus ffamily_name_family_genus_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_genus
    ADD CONSTRAINT ffamily_name_family_genus_fk FOREIGN KEY (ffamily_name) REFERENCES knowledge_base.ffamily_names(ffamily_name) ON UPDATE CASCADE ON DELETE CASCADE;
 [   ALTER TABLE ONLY knowledge_base.family_genus DROP CONSTRAINT ffamily_name_family_genus_fk;
       knowledge_base          postgres    false    235    4925    237            b           2606    110461 *   family_group ffamily_name_ffamily_names_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_group
    ADD CONSTRAINT ffamily_name_ffamily_names_fk FOREIGN KEY (ffamily_name) REFERENCES knowledge_base.ffamily_names(ffamily_name) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY knowledge_base.family_group DROP CONSTRAINT ffamily_name_ffamily_names_fk;
       knowledge_base          postgres    false    236    4925    237            d           2606    110466 /   flexion_stage ffamily_name_fgroup_no_flexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.flexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_flexion_fk FOREIGN KEY (ffamily_name, fgroup_no) REFERENCES knowledge_base.family_group(ffamily_name, fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY knowledge_base.flexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_flexion_fk;
       knowledge_base          postgres    false    239    239    4923    236    236            f           2606    110471 7   postflexion_stage ffamily_name_fgroup_no_postflexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.postflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_postflexion_fk FOREIGN KEY (ffamily_name, fgroup_no) REFERENCES knowledge_base.family_group(ffamily_name, fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 i   ALTER TABLE ONLY knowledge_base.postflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_postflexion_fk;
       knowledge_base          postgres    false    240    240    4923    236    236            h           2606    110476 5   preflexion_stage ffamily_name_fgroup_no_preflexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.preflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_preflexion_fk FOREIGN KEY (ffamily_name, fgroup_no) REFERENCES knowledge_base.family_group(ffamily_name, fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 g   ALTER TABLE ONLY knowledge_base.preflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_preflexion_fk;
       knowledge_base          postgres    false    241    236    236    4923    241            c           2606    110481 $   family_group fgroup_no_fish_group_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_group
    ADD CONSTRAINT fgroup_no_fish_group_fk FOREIGN KEY (fgroup_no) REFERENCES knowledge_base.fish_group(fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY knowledge_base.family_group DROP CONSTRAINT fgroup_no_fish_group_fk;
       knowledge_base          postgres    false    238    4927    236            i           2606    110486    preflexion_stage stage_name    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.preflexion_stage
    ADD CONSTRAINT stage_name FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 M   ALTER TABLE ONLY knowledge_base.preflexion_stage DROP CONSTRAINT stage_name;
       knowledge_base          postgres    false    241    4935    242            e           2606    110491 #   flexion_stage stage_name_flexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.flexion_stage
    ADD CONSTRAINT stage_name_flexion_fk FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY knowledge_base.flexion_stage DROP CONSTRAINT stage_name_flexion_fk;
       knowledge_base          postgres    false    242    239    4935            g           2606    110496 +   postflexion_stage stage_name_postflexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.postflexion_stage
    ADD CONSTRAINT stage_name_postflexion_fk FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY knowledge_base.postflexion_stage DROP CONSTRAINT stage_name_postflexion_fk;
       knowledge_base          postgres    false    240    4935    242            Y           2606    110192 O   auth_group_permissions auth_group_permissio_permission_id_84c5c92e_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 y   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissio_permission_id_84c5c92e_fk_auth_perm;
       public          postgres    false    4883    225    221            Z           2606    110187 P   auth_group_permissions auth_group_permissions_group_id_b120cbf9_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_group_permissions
    ADD CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 z   ALTER TABLE ONLY public.auth_group_permissions DROP CONSTRAINT auth_group_permissions_group_id_b120cbf9_fk_auth_group_id;
       public          postgres    false    225    223    4888            X           2606    110178 E   auth_permission auth_permission_content_type_id_2f476e4b_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_permission
    ADD CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 o   ALTER TABLE ONLY public.auth_permission DROP CONSTRAINT auth_permission_content_type_id_2f476e4b_fk_django_co;
       public          postgres    false    4878    221    219            [           2606    110207 D   auth_user_groups auth_user_groups_group_id_97559544_fk_auth_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id FOREIGN KEY (group_id) REFERENCES public.auth_group(id) DEFERRABLE INITIALLY DEFERRED;
 n   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_group_id_97559544_fk_auth_group_id;
       public          postgres    false    223    4888    229            \           2606    110202 B   auth_user_groups auth_user_groups_user_id_6a12ed8b_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_groups
    ADD CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.auth_user_groups DROP CONSTRAINT auth_user_groups_user_id_6a12ed8b_fk_auth_user_id;
       public          postgres    false    4896    229    227            ]           2606    110221 S   auth_user_user_permissions auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm FOREIGN KEY (permission_id) REFERENCES public.auth_permission(id) DEFERRABLE INITIALLY DEFERRED;
 }   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permi_permission_id_1fbb5f2c_fk_auth_perm;
       public          postgres    false    221    231    4883            ^           2606    110216 V   auth_user_user_permissions auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.auth_user_user_permissions
    ADD CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 �   ALTER TABLE ONLY public.auth_user_user_permissions DROP CONSTRAINT auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id;
       public          postgres    false    227    231    4896            _           2606    110237 G   django_admin_log django_admin_log_content_type_id_c4bce8eb_fk_django_co    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co FOREIGN KEY (content_type_id) REFERENCES public.django_content_type(id) DEFERRABLE INITIALLY DEFERRED;
 q   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_content_type_id_c4bce8eb_fk_django_co;
       public          postgres    false    233    4878    219            `           2606    110242 B   django_admin_log django_admin_log_user_id_c564eba6_fk_auth_user_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.django_admin_log
    ADD CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id FOREIGN KEY (user_id) REFERENCES public.auth_user(id) DEFERRABLE INITIALLY DEFERRED;
 l   ALTER TABLE ONLY public.django_admin_log DROP CONSTRAINT django_admin_log_user_id_c564eba6_fk_auth_user_id;
       public          postgres    false    4896    227    233            k           2606    110501 0   family_scorecard family_scorecard_sample_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.family_scorecard
    ADD CONSTRAINT family_scorecard_sample_no_fkey FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.family_scorecard DROP CONSTRAINT family_scorecard_sample_no_fkey;
       public          postgres    false    246    260    4951            q           2606    110506    group_decision fgroup_no_group    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_decision
    ADD CONSTRAINT fgroup_no_group FOREIGN KEY (fgroup_no) REFERENCES knowledge_base.fish_group(fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 H   ALTER TABLE ONLY public.group_decision DROP CONSTRAINT fgroup_no_group;
       public          postgres    false    238    4927    258            l           2606    110511 (   genus_scorecard genus_genus_scorecard_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.genus_scorecard
    ADD CONSTRAINT genus_genus_scorecard_fk FOREIGN KEY (fgenus_name) REFERENCES knowledge_base.family_genus(fgenus_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 R   ALTER TABLE ONLY public.genus_scorecard DROP CONSTRAINT genus_genus_scorecard_fk;
       public          postgres    false    4921    248    235            s           2606    110560 &   sample_master sample_master_stage_name    FK CONSTRAINT     �   ALTER TABLE ONLY public.sample_master
    ADD CONSTRAINT sample_master_stage_name FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 P   ALTER TABLE ONLY public.sample_master DROP CONSTRAINT sample_master_stage_name;
       public          postgres    false    242    260    4935            p           2606    110516    fish_ratio sample_no_fk3    FK CONSTRAINT     �   ALTER TABLE ONLY public.fish_ratio
    ADD CONSTRAINT sample_no_fk3 FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 B   ALTER TABLE ONLY public.fish_ratio DROP CONSTRAINT sample_no_fk3;
       public          postgres    false    260    4951    256            j           2606    110521 #   classification_result sample_no_fk4    FK CONSTRAINT     �   ALTER TABLE ONLY public.classification_result
    ADD CONSTRAINT sample_no_fk4 FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.classification_result DROP CONSTRAINT sample_no_fk4;
       public          postgres    false    260    4951    244            m           2606    110526    genus_scorecard sample_no_fk6    FK CONSTRAINT     �   ALTER TABLE ONLY public.genus_scorecard
    ADD CONSTRAINT sample_no_fk6 FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.genus_scorecard DROP CONSTRAINT sample_no_fk6;
       public          postgres    false    248    260    4951            r           2606    110531    group_decision sample_no_group    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_decision
    ADD CONSTRAINT sample_no_group FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.group_decision DROP CONSTRAINT sample_no_group;
       public          postgres    false    258    4951    260            n           2606    110536 5   shape_characteristic_result sample_no_shape_charac_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.shape_characteristic_result
    ADD CONSTRAINT sample_no_shape_charac_fk FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.shape_characteristic_result DROP CONSTRAINT sample_no_shape_charac_fk;
       public          postgres    false    260    250    4951            o           2606    110546 &   summary_ranking summary_sample_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.summary_ranking
    ADD CONSTRAINT summary_sample_no_fkey FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.summary_ranking DROP CONSTRAINT summary_sample_no_fkey;
       public          postgres    false    260    4951    252            *      x��}]��F���̯��T�N����x��9�S�ɞ��VmQ#qC�:��׿��ߤ��H$'�Gh4�@���i��~�_N7�~�wc���D�"J���r%�Y.b��ϯ7�X-�%���"^���(gp��VwƧ���58^.�����?��m�V|����E����z�2T��4�r8}zÙ����~;T������G�HQN�H��1���8Yę` �<����O@H-��*�c��7�I�W�/�#*�P�!/q���Q	����f_����"�x���&�E�"&d�����Ip�n榅�\����v�j���^���Ƌi'9�<ɐI�Ϥ ������ܑB��)�s�����_U�ٟ�<ں�f�8�����K.v�!ƹ�����%JN�X��υTU��и�s90�_O���p�S�
`I4��r<�a1��p[�d�>J*����o&QVwz+�A$�~3���P��c�Gz1Ġ�_P�����zh�k&a��{�(9���IL��O%��z��=�^l���:��K<K�&d�~��_7$�9
{\.��c�*3E��p跗�o�5��? L�-2>�rC^�t�,]�bϽo��� �11`G��)�"��)�j�	R���=b�EӶ[��E@y��S1�N�N�}��if_(�B��4��C "��U�ja-�!�2�c`�7 �O�T�� ��}O��Ė�$z�Ĺ�t���+h��whb���j]�k��'�jF����Y��8)΋�Z�����d$�㻷�3�u]4�o�o��$d��"�E%y�wB[��`�1���4��n����*a�a���x7��Ǚ���C=l<�d��y +@�}7u+Ԧ�Xgo�����.����k��ܷa���R��Ł��C5:� &�h�� ܘ.7K�]��ߊa y��+Z�Kn�j�����{�����I��^�LR�RZ��C��Ȍ�O���'qJ
X�R������24���W�S���k�z�L�p}A%�}�
uouw��n�W �NK;&�P ���C��x�T�9��Q ��"ߘ�3�c:��Lb�H]3O�R�Z0s�@$C[���ԇ+���敋������,�8��^w���Q?O �Q�DI]�����9��(x������eD���3	(�BY���yL�ہ�i$t%� y`gwJc���k�̅���q�wuw�
IZ��j���R�+1�~�UA��Q�%��;j�H�	��PuW��*`�/Hb*�$R�m-��wn�q_��g�X�F�,2�}�t��x��b��نIL,M4�o�8���b��s)�p\(�)q�C�>��iO��C{>J��_�m�{\j(a����J�J�5*6�Kݝ�F7U���Rz��Կw�I\�~��jd0IW�����.R���G��%��1��}
Qb�>��m?�X��J�ѬMC�����j7l��n�)�r�eJ`ti��CN3G?Й��)Һ���S_�#m�)�����V�(���4q/o��P�[@��d㔰�塓��;SzY�EV��T��+�3'{pF��?���2��LP��:]v�J�^�G��~�� T��X�-YX!K�Ԓ�H2�8x��M�����WCX�I��$lgi~f��J�E
Z�8���ſ༷�Cj8�Kc�!�:�.]�;� ���/� ��0:v���D���󪣸r�p�9 ps�r��(�AVxl�B6�/��^^].b��g�`Ų0�9i.m��f�3s�č��˅�S�3��	#��~���P����C�U8V�Vʝj�Z>�2�.J�N`����p�C��Mp�)�c���'��$vL��7-�ĺ� ��2���,؃�k�����?.�.%������o��Ђ��X`�1��T����S��H���`$r??U�s��ݖ%�a���_�]<6Ǧ��@7gZ�d�r���E&�y��^�A�<vQ��9'�@yًc��%yT3CwtV�4�(T�#8����^���[�]���X�Z�c:��gL'ь���r�Z�� C�9˴q�m�?B����w���
��D�pt�'� ��I�r���2��W������ o�L|]������;2���j�a��]��m���0���n8w�) �ņH��>�X��*�؆ge����v�s/���I�O���d�0�9IǀЩ�R,���ө>���^"w�\$)�[��K�'�����Be��y�K�kGW��]vpB[(��v��f�7	�ܼT��D�W�����Y$���@���gj��B�$�> n��<����LA��$���|Q�c��Q)1���Pm���;���*��Q�-|&�6�bb�Π������Fߋ��QO�B6䪈ٕRc��_���,����C[���&��u�Xɥb]~��VH�9�/��&RQ.J���#?A<���aZ01�Y^}��R��IeF��ABOV�aK��I�3���e�T�������F�lr�h��ZW�(��^��I�j��������ߩش��6�O���J�B��Zɑc�TWdT�"c��1�X2�1��+��7�$0_۞��,Z��G�w��>FV|���� /�zӴ��I+ɤ>"����2�����D�����de��P;��Lr�6խ9:H��Y��3Դ�	��ȓ������^� ����/��.�|�!�'���n!ø��Ι|���=��y�g[��G��߁�)&D
;��R�o"[���[�G���[�n��t���=6�7��2�SW������~����7lOA1�����Cxb��_����,HbJu�Ls�������_Hٙ�σӳx�:�H��~$a]����� �ۂ��c?A��q�Nr�C=�1"~����ƴ��`�?�1b��S��qѴ?&O��<�9���:�E鰇IQ�wp�I?�:��Spr��AT�7�i��?��(��¦� ���K��jh�\Zۿ�Ϭ�/1
d�E_4|�{֛u*���(v�`#$ڪeoR A������C��Ls��龫�ζ�G��g{o���{q�w�ﯴ�i�88�{q	NU|�n��%ˎzs�LER�ix�L=5/E{�M�þ��^�������C3��c~i?��� 
������Y������W�����5�''~�g�] v(�Ƨ�b���8|c��룭��h\�p��g����`�܉=��c
˷��O�o���Χ�@'@@ YA���\�+���~�c�wze�B�]��^��W[�>�m����rY76f�oX&�SB`������	��h���d�P���&�G��Y��E� a07'�T����K�s���^�y؋k�(�)CԀr���<���B��y+�jr��e��@�I�|�\Z����c��(���K��p��x^�pC��8�7}��� 6(G$p�ud?���hlO�X��%�)4�ݽJG0<>
�~;y�޴�3�B������8�Q�`���+���Q�I"���\~*u	A� �T�|,�}[c��Ɵ(X@��R_پ@�Q��-��-c����<5����õ��������%<g�;lӐkg�alx��Q�^NTq���oz仞c��t��9o|��1?��A�Üc?�� �m�"���&LPl� ��1�~��`q���q�2���_���6�ׁH��3!�w�o�x�B�^S�T���7‭�W�<bw�pu���c�`��d�_HsJ�<��b����_�i�>�����<OB{a�ѕ�@��Ӝ�	��o�n�_�(��N�!3\4�.�o�*��/��������V�2|�K/� ��7(L�4�����0Vy���|�0�>��cڕ��O�4���wMt����^�}�O��7��&G�ok셩�� C �& �-B��=<� : 6�l�������jj�	�Wo��k�.�6ߔ��Zi@�@�oöj�0�l'|����1�Hfh�U,~�5��� �o���^���oU[�>�3m�P�3_����Ꮦ���&�/����Pz��ә�����9��Zˠm�p<��̖�*��|��oϤi��iӷh    L�ҴqzU�~;M�GLB<o����
��]�� �A>���\�OT?H�$$��j0��i�p~a/Ufi5�+t!͉�IN���1�s�2>����b�:뇞����&�Cs�8з�ĉ1=�RAi/�P�����p09��������N�>	!N�#��,�1O}n*k=3�̂j8�kZ(����S���<�ǘ�.i�[j7�@j���H@�?�M��rȡ5�nP�_y=���9z�X�؏��4K��U��i�+����m�!��xz{���!�%[�Z���o{p�U�������y�Wp��J�XV�'�̾�^�(䲻
Kp|��`��6*��
0��J��8�"���3b�g S��I�6#�C��e�
��R�wc�C	�E����<�,L#�_
�
"��>��<�Rȴv��/��wAO���ZTN�h�j� Ѣ�X��Y�9J�|&� ����g��qD��4A�/ݣ>=���9�ů���Y [�t �m?�������CA\���'t��� ���qO7@x�5�c��|F4�2��c����q�VN�l�ZJ��u��w�g�D�61�ޔ>N*#@����}�G3���YJa]��B��v�� �X�vR�{����"��_7�O�J_��܌`���4l��+��w}3r �Y×�BJ����+%�<��S��U+Ԟ�B	cAU� 'l�L��{aM�T��(P�^��	����%�T!��Hd�
��4�C�<�ae�N�~<���<���_.'q*���Wl��b`ul�j36�4J;�,ewE�=[���U�FF��Vu�V-I�	o���S�#h���t=���(N�4���lț���2�h���	d�O+�#Y���ot=������#$�!m_;�`*���E�d��9�����&V`��{�����KL�p��9��Y,����\�Q�j�xR
�W��"9I���f	e����;�G'%U�Ws�ku��US	���$�,R��ԔT�>���0؜!�DZ��a���x?�@���zyo����ysb1�N��/�j�?���Y�^�p2<� �`��A�0N��8���U�D��:'`���f�D	��ٛ�1����A��n*%(����Y,k��~�t�k�S��S�8��� ��-m�q��3���p��#�c�$H:��S%�`e����'i�T��
�H��F��W�D�e`ƿ`���T74�*[�e���A�'@���#�L)3�^0 Xoܰ1�'��^(�*�د�b�	t�3��!E�H��)e�� v��N��5,7�����\�׵]���t�3��H�V\�$vm��������q�=���]��$��a*3����Z���F�MZB 4��g��+��x­�q^�IM�X� ?!/���l=UjD[�K��iSG�M(������J�H?}�ɓCE�\���&I�mfW�y<�e���R~�B|վ�y�r37���W�dd��0��&�%�9����+$q�cVJ}�y@�v:��כ{��ufK���	��c����Ϻ�7c,�L3PM�F�^��p��4�l�R�v�Ŏ�TS(oEU(�02��7=��C�c}�0������b�J�@���4X z���f�/��Ag��v��bl�������<�孰~�p��5�,4)l/ ���.MK�or5�K=���B(U�:�B�d����^�:��Υ♬T�l�O����!p%��^��X��$�'�m%i�
�q�Z�w-�z8Y��
�#hfV~]<�Gq���RA嶚N����~Q*U��9��P�'Pc��B4C��^!
L��\���V�j�-}IW�2�ڻ�[D�'��Z� �RX������BA���n�ڋĮ������ �N�]Y@9ɴ
�
LHV0���}��N���0���-�S����f���F疣V�+�yB�!����<#��P��X9��/�?����*دA�%UK��j�;5�K������>Bx�'ƶ�}т 7��b����EW�0*zkz�� �a9Ā������cJ"��\�@L�j���[W�����mu����)���������&��ԧ���������F�>i��br�G��<�?	����k����6�eJ����4�3ǇV�a@9.�,�ݥ���&FL�Hk�
A�|��[�	X�� (i�� �D�R�oU����r]�9��RÐq؀�z�)���J��P��W�+�c�7�A����*x�����o\
�(Mn�2FQ8
��,S���3���[�.��s�P9↹��a2�x���G����=KLE����!�Iv�;�f���E%	�L���Ό�3f��PU>=0]|+��r�r`5�ȕK]�e��8x��u�9[�
��g�[31y�ǚc�	�4S��Ƨ���� |Ӝsg��uOo�#W�)ui����%����j��dƑ���x�����T_��)�[��GX����?@&��*"W�V�Q�)'Rt>�Vm{��Eo���h���^�c�B'�	�g�8mA�m��Y��;�{d�L�Д�?���M�9��C��?�[2y�<6���lfHJ�,G��R��}둣ئ؈��Ks�߄��BS�^�@�ү쑷�>^�\��$\�o��W���)Mx�>�C}n��+�����zZ�'���K-��U��=4�߶.���ę�}�<��@t�����<V�Ld�A[9�P�K ���]�Q�i*VT,1�.i����`zൄ���_��ڣ�7fXA��rj=erR0����P�E����bu�@!0�fU�Q��1f��"�PN3��+0��b%]ƫEA�	�?\��B]?J�YߙK��%���DʠL�0�)E�t���d`Y����JPзU-Oj�%���%eI��T�b�D���/աߋS��\��bp��O��0]"J�#*&��4�p*n(u��h��Q03��|Q���:�	x���dQr�d+&�Sėe�$4\5�8be�.��%ڂ0��t^ST���N�D�[�6Wp֕���,8	[U�!XĬ��ޔ���'bros��]hU�^��wm�[9�seIYл���ʎ����q�U�g �����,���)4����`|5��`�� rB��-*F�4g�~Ry-8�N������vK��7�ͱŘMݜi�N�kT�-(�Nzg�(� 1Pf���~��0� K"����.`�!�xU�VSk�9�8=v�H��o�:,..��
�n�ά��c*��M̞�ͬ�Yd�sd�u�F��S�����
m�nf�T�e�ϸ��B��T�f���~����W}nW�wc���2�@�6�0����Pd*]�V}��Q�6��e���sL-���* ����*|?{������Sn[R�'2od.���[L�Exn�y�b�=��q���
��q�Q���Ƅ����°m׽��%�!%��޻�Յ��e��m�5�6E��b:&	f���B��k�h����}�K�������A�.1)�Ob�A�k�f����N��j������+kć�UY��gnjMز�\�p����-�S�$��]���F>5&7��K9_������L��k{��ߜrɧ���:\K&+*hql��)W�V�*t���}�Λ�&��$�I"�5��������O
$,�Cf���Y�ײy���zB�&��Վ�N�|����RcJY���1�u ̶yP�Duu���7l��N��5r2c�&o6�y�zy��D�ɡ4I��t�`�ۨ����y��n�'�n�B��®Q��X?Q�Ia�朖�\���󀝒����nF�����J��������M��Ԋі?��r��_�PX<������tTˉF����LH遨�N!�iꓥ�ksݬ��$Adf�Fh߰��l�[��/��BMK(�}��	��<�$��o՝����iDY�U:�:�\,c��{�x��4Zux���H�A��o��8*"/��*�� ��k�e�M$��*��B3��N&c    ������6ͱ�A�,'ց���6G+��t��a �:����R.䓍GgC���<6�+�q�����Q�DvT.)<7s��mES�"�j q��u6�
K���-�q�֖v1�RW/�Ԓ�P�B�X��GuZ'f8�}�p*>B8�W^Rϝ��=T�N&�ld�Ty�7mk�.:C�	x��r0���a�A�F� ,�0�{`~��n��c���0?��~���r��_�I*��3T|{�\��<��'0��d�k����eovቝgƹ"������k%���U��Q��F���*ô�X����H�ߺ&�$=����9a��������~C>@����p�$M?"`����ziǑ���τ�x��#O���u�fb�Fs���-P%���t��i���ӈ
��-{lc�rU;�X�*x��I �[�<�_���$���T���Y����MC#x��?������U�A��\u*�):6���
�*�$8+6�������
 k�ɣ� pM���y���`�O�/D5��L���岽��cu:�a��5\d
��KdPp�]B�HDjm6_6�XJ�p��v�$[w�`ʞbJ�VǇ���S3���X_-F8��Ȩ7a@��ӕ�s�w��b�@E��چ�Xq6^����Ld\F2<66�Q�>(��O���� ���Y����%I�œ��F7'5���t��;rd'��)�VBt��__��ڂ��ְ�?�����:����_�qQ��)4@�ob*�}g�p��5��|��K�"c�Y*�8>4t����pn��N�N����W��Qt~�z��"$x�ꅮ�3�`(��a�F!��`d�.B̅Fԉ�'
�z�jɧb~W��[������βCl���-�q�FĻH��5�v�),.�͟��K���%�UC$E�����I�Ed�$' ��E�g��}wc��Rk���q�2�:��Eॻ����d����X��
�a�TN�z-������ɂ/�����]ʒ_�倻A��m�T�,�S�GdmKu���E�Tu#(����'eܺ(��]���1��?�8��E��-�M�l���S$��|O��j��\@/01*�c�F���8���%���u��������s���e�ҳSɅ~#�1�m���ӗ|-�zr�2��J���50s����W���[Y��&��U�W'��y���b��N��B����p�l���k�"t����p�;�t�I����AN����/�S@DJc�������jir�����A��6��������>:\�TNv��L?������('Y�(3�ح�4����5�@�yh�Vq@,��9�m�0'P��K�[�<yO�w���3BQU�̄�Oe95O��R�����p�"�%�ԍ^���ǅ@��bj=^ ��$����v.��$���SS����kA ��O/��ʈW	�l���w���8ۍ�V�~ȃ\�VB�+��7�W]^f�vz���=�h¼���,��H���͎�������j�E��{�Qc�Nn�)�A�.��Cqv:R؁�v�'����f�������[}:6�lA$,��*�'��(Y^�\x���mU��p�CB��0gxf+�W��j�x����荒�6�`d�{}��$k�ݞdN*(�m�N4���9����+���8N��B��Z���s�uH��(���Z��A�(�ou�8+�m%p�;^i��U���
�"�j��^}����#t?���I#��7�ܘ����t�ƿ7C��uȨ��Ƭ9p������x̷��&�\����(�r5�幆�JHj�E�ޣ�?�5h2P>S�4G���2L-�T����EJ���B��H9V��0k(��:4���D$jW�|�:���*5��B-h���a(OVD�?��o#Ng���>����2õ�V���&Qz�S����n���>�۹�p�r&T�B�t��oտ^ܫf��*��K��MZ�C�C�Q�O"���!?����A�����C�A�� 	\����Z$�Jt�iQr��ҟ�M��[4���^�ȩ(ItS�r��<MU%�pFn7@.��|�$+�VL��t,a�T�F�`�wJ�.;�Ĥ�)��y�P�p�Q��!Z>��U;!k�Ȭ4ܳ�Ǫ�D� W�|XG��0d��[5ЗX2�#�#@4֘�ɩP�7�+/�
��:�	�U7l��+D)Js�P�|�������Oa���Ȯ����aFh*��a�_�'�}nR���4?�1f��մ��"w`|v=zQ�YiB¼v�A�����X��֞B��76��i@���?�|�q����P�o*�B�W�f!,W�S*N�����B,�`��\<vYY����Օ��O�'q{"��A쩔�X��m�h~��3ÈCܐuц�
n���J�+ �� Ayg��¼ڳ��Q5[��P��2�K�\���J�珵L6g�9��'M���\�r� �X	�Jc�:(lKk*1H�LC-hN��Ldd2d4C}X��J��R>"�eIL�`�]���؏c�������J�1I�.9$b���'epY0��gX��Ùl�;
qx�X1�!�����(�TCK�'A�\Iч��;�7耹i��C��0"t��[K�6�K��j�~����?�k��U,�/z��`����S *_�� YQ���$Z���b>V��1 ��-;�_B%��{��E��M���؟�z�*��A�2-/��Rc"�"'J�D]���ON*�{kT�%�^]�O�0F��Q�"�E��N�L#&�@J݁�D6twQ�$�����`�)gf��
2�X�k��`��6�8�(�H�?
�@��Vy��ȥ��ԟ���׻m^��ĺ4.6͸Qو�yԵD>�/��]����8�e.@_ҋ[��O��-��p�O����Ѵp�L8��Cw��OB�� I�N�2�L�8�����s���V8�ܱ���}{�}��#�Ĵ���N)�����n�9k�8`{;�0��V�N���R��b�#��9���y� �V������9P,�n�R{���c'z�:o�����Q��t�?<�oq'PΙ�Z�1L;�2o��p{a�쪓�\[LJG��)����k��)�J��e��A/۾����n������d2�=�s�_��ь�S�(�`'�!��B�Q8���H6ǭ�37;Y�HF��7R+��N(?�\���a��)��i��4:>S���L��Lg�����h�	E�<���4Tj_����}GP�p�X��T=�R�N�~z����8��G���X�l��N��,��1��]���λ��U�M��E�x3��i%\Me&Ӗ������PͶ��OV���߾���U"[�s8��z�Ψ���������Є a�4luh�(D�N���0?�'*"�Խ)D%��%���a"uA��r�a�00n��^��?���Ru��Z~�F�p��Gm����l���'��
B%����zw��(��c˓Fz>̷�	=�Ez�8Ψu.҇��
���ݷ]Ӯ/MH�!�,16!t�C-�n��յ�-e��^��x��}7����a B�*B��W��>��,�}�C���L(tx�>א�3��ʃɕ�*������m+#8�weR*i�ҕ>5t�LY�{�]�*%�UnTsD�8�ʟ��P�9�s����@bX_��xa^�ϛ�3��
N^�6��W�j팎�!O:�'�}_���UcFוQ�m��"8����=��*�1a�^?�Z�n%��=�:ć�r�c+C�����A��@���z���eE\�vLv0����@�����Wo��>>�X�GzɌ�ϝ�6B��H�i(�%���k��=�Os�L�������>�?�$Z��� *!F�+LR�Tu��$���R��`����O�L��	*��Ϛ��fc�d���g��2n��J/�5ʱx�d,aF�ڃ˷��8,iݯ�:��.ɑ��Ŷb���6v��6�us>�"�#��w*��ۚ�Dpc�3DD:�)�4���?� .	  ��+̂u#vܰu>��&�a�C�R�.��,�}ם=���8�� "�������s�?j Q���A}�Dr�B�_���&Tu�z���h��(T�N�~�<k�?v�1�,�bbdj&�q٣�[�a>	+c=� 	��M��]s�<M�ש�6�YIb�������]��?w�|,��T �e�~�V��(��K�y! mbs=遬���죠�yT���Hu��F	f���z��N�?hw�6�6:� �<���������.���������F%�P�f��KQ��2;'�0��MkN�g���P�ȅ��">�luy�X�sI�E�]�d�q� ח1��#8�T��pl�%./J+�36j���.�h��bZ�H9��S���Ӝ�q����3�{l�����m�)�xRd5
v�E;_���� �����-s
����n�A�4�٣�z�nS{ġ���.�����Щ�gp�HZpx���ff?�� ��nd��@��@���v�7bķM@�
���s������DN)0pe������ǚ�C�Z�|�[T�����\
�9��Lb�Bc�_�,��Ĭ�2%V�Q�j�W���V[JBt��!ƙā�3UksN����!�z��ipkB�ɷ'����^�h�S����K�d�,�R�=]A��qǄ)ɸ��i����\��^5)�s�iR�uy�.ۚg]욒���벒��'�47;��i�.�^`D�I9���4�|���PA9�������8m�p;^;XoU��9D��ĩrÑ��p��������s�隐͖�4�ۺ�۶��п&����_Hf�v46m[����~.�S��O\�@��jצ�30x�����TG�e��%*����J1��s����	Rkw�o<f�K��ࢗT�~̡O��g(��m�44�A����YR#��h�u�kb���eF�1&�F0*���N6#9�A���� e+,�j� U	ߠ�f���F����@�X��*x~�ZTBi-9{��,�F?�?ԍ#�1(��j���pٌ2*� Dq�THEnN$旹����[M�
��Y��Ӽ�V�6�Ĝ ��/Ƙ�a�.��{I�I�.�ovd��yR�#��b.���K���hp$�HU��	Lt���$8J0�v�MF����0~�eai���0@���7"b�Q�9=����@$�R6J%KG{@hc	R 901�G�@!}]�Α�yȷ]p��Ze���U�S(W�Q�%��I9�g���;6��P�U)���,/�z�u���1@�G�N>w.�f=�����rI\��#�&V7�������/,E��
��ݣJ0j�T2�^�w>�C1+�8���w�X����ri��1G��-�ӕhõ���<N�OD/92�b�$!��P���M"��?�C�3��MH�;�{B6�xc���PS�9c�l7�Y�Q��1ze{A�~\V���L���O���}���uM�����58ޞ�a� N��Ԧ>597��b����?�Vܷ�~E������q�T;!@�r2�M�9�dr:8, f1�9j���F��7�Za�xҊ/'jc�it�L�o�|��\	�aL >\\�-ڤ>����g(Q�{�l_�'BhUy)Oi�#A2JME��V�r�~���X���iK\���>cj�������}j�،�W�������R��^[�NŹ�P�ܛ0�f`
=��ثJ40p`��;�&�?��sH��΍�Q���R7���)`9��$!�x�U^��`D:J��|=;����(#������a:L		LD�B��]���P�
�5�O���iYw1���NL����Rh"���\��0&����v4Z��,�a��j\���#�]gbP��K�G��yw��A�;+0�rc�� ¨� ����|��}��=C�pX�0wH�ۀp$�r��6M�>׋0#�W�d�Y`F����+]��J�b�@��XF�H���(;	�e�^�aެz��q���(2��|(N!�6���>�^e����ev��&�3��&hCڴ�T'��
���>��l�@�_8D��O�H�(�wa��a/��GN^R;�<�\L�eV��������x�fA�9ӆ�@�2L�Ҝ�K��8i���	����P��i�CZA~��2���$W�(;�oC���(*��Kk1���
�@OL��Kkv���}gnb�r��&��b�DK'�@�{d�*���e��V���mP�R�
M�;B�����X��9(�%E�����Qv\!8�3�p�lʊ�%aleA$:�sB�D�O&�]#�ʥ�f'�3*��_����ʠz      +   �
  x��ZYs�8~V~����{+I�I�;WO���ٙݩ���%F�"��������:<��l�>t�C < � j\i��RČ�=SeZ;4�LµzEʋ���6�D�s�17ݍ��.��ŧp�KQ�U�%���òق����p�M�J^#"�Z�B1�腰lW\�?��spd:��s������㍔#)�Kb^�a��F�vv�-�R$i��r����^�'�.�R̸�]�Dr��7:i8O��L��؜Ôh��)|��%�@���{p�Qs�YT
��3�o�=��N�N�#M����l�g[��R�r�'�Lj�/t�[p�)g��w%uQ�̲=�*������IQ��$��Q)l3-�p�7��y,y��;����:#��sSG���Å|ѪJ��S�N�����>�'�Dre]�wu����<�n�����e����e?����i�����c_=�c���h��$V�Kb͡w���u�m͘a;6t�]���%���]k���"s&)j=�V�U�ne_�����:�>�a0���4��D�A�ѕ� )�o�B��$c7��A_�DD�T�>�਱�'�IV	�g�&rftU�W�|��)���|C��������b;`͹�̑Z�. '%����6Qr���D3�a���_vgD{4�&�k�#>��l�`ӟX��t�3���k��>&�Q9���)��+w��jg���v��~|��$�.&'���3\A\�Z�����%d��F��σ)W����6Բ4��H\3Yp:�Ʌ+�av2���\Kw5��;<M/u�����
~�u�w0 ��C���)��l"���{!_�	�׌�L)R����;ܽ6��r��hq��
c�Xy��_;S�'�D�2�+	kE��R?��2��Le�s���T�Q ��`��T�j��1f���oQg(��}�q���2H j5 ��G����A�7�7��Z�g*<M%\^Ko���qpim�s8��.�ƎÛʠd�m�w):��iU�jyw)/ǵ���e�J��m11ѫl�O�c��~\VEQe�[�d��yO�X��_f�:ֲ��]D]����ܹ̏��<�v�
zBYa�К���Jr���rTr���Qp�e\�(-k�E��2�:Z���v��*���(�o���~��B���>̖��:���v���0�\���8�rߠIk�"�]0H���fy3�6��?���"�$%k�9����NaWIQ��ư,������;�����9v+�L� ��i��(f��k���MCD�[w��U����1n�����UmĢ6P8q�K�	����h�PW|	\�P;H4�!�6�m$���H;����6�rwr��Ȟt��t�J��: Mw�5?g�<��1�ʚ���Ǖ�;�9�n� iw+Q��L�� ���7��T$�L��bm��ɗ6J
��Mj�#i�>�S3q�!�[��ț��{�ꢤ�ki���6�`B�����·� ��ᬡ~	A�c�O�7�%���6b��tŽ���n���8��[�JߦM��k�&%D�һ8N�o5OUw�^�.�����f�1P���������Cg�C��XT6��UM��)$��Iv��qB�6Cnom����(��*��l�)/���x8^���P�6��/w����nʴi4_e�`n� �?Seb8ˬ���n��9B.�SJ�qM��	�T��>&�U��V�+�St�;��
!	Y�w���f����G������h��%���h� �ܗo�-J�Edtט�#f���\�̦��/���dm6Ȉ��굀�8���h_N����g%U�='�^`�!Aӓ`�����[����r�R0ܓ6���s�5�"��>$v�118O�_nW�"���e݁�'�e<����-�S�����m�-A{��	hP�1m :	���S��S�����/�#eM���5��ӯ��s`�^H���w���(�|]���ٓ�����S����r�jC���ɍ���{M0�:�@	����]��	���j�D���*.���ׅ�6�����}I*A�
o�j�Gy�g�uψm�a ��g��eM���IЖc�3k!��E�-�٣�+/��paA-kų���g��u�.pews�G[�~�6�\�񮷹�ج���y������KR�v��GŹ*$%F ǯ@-L5Nk�=���x�XG��ӗF\�V/��y�9�y����B�3T���>^x��;5M�QY6�Q/����Y曄SËr�-΂y䉸�F�>w�@�%�K��l�f�~�p�0�O��e���?�V 	�6�n;�.�1�hbj4�(
-���Qg
�S"��]WDA<�M�Kۼ��P�j{�͎��w^�~��J�p��/|,a�H��[,D�L���P�A1�g\R��ض�P�8�:����U���+�f��-��A
ʽ�5�x�M�*��$L���ite˒�����^ꂩ�O{̈́��)�tݣމ��fnCEO`kV�aO9�y<s���͂*h�O@@^����R6F~���ý������d�{%z^��T��6	�ʥ�~�5�`�/D���M��>�j]5���Z��ރ��3k�{��]�7��# }���k
<Am�.�	���&Jn����ͩ�O��i�E/�|���޾i��_pӢL}�A�&55گLE��6J��Z�)6P����g�����������z7�      ,   Y  x��X�r�6}6��o��٪�X�/���MvS�JAd��DsA�^���4.�lj&y��nܺO�>Ж��S�ǋ��GR�V�頜kv�"����t���%��z�h����������ۉ��4^��`���-�����O�\�����<h����N�d�Y�﹙�ꕲM�W��q�M&�c9K�l{�:��n�G��Z���W�5�	Ύ۳[��9*r�K�^zY>=��^|ê�tt���+-��r�*�`A�-SG.M�4�8�Dq��#���'����~X�(��)t��K2i�G��P�۞m��Ƚx��O�d�yf;j������[��jȆ@��MNT>R�C�S_l�?M�SW�������S�'D��V�)�}�������-���'@@`oD��8j{U��)eըV�喛 �͌��4��,D����؏�S=�Ul�1* E����ۇm2��6���8C��cNwN��V��؆U�% �B��'w�5�u�;���mWqI����~�!�*d����?kD�}�����U5�Or�?=����-�)W��
ڒ����vk�	-7ʌ$�t��L��M�6X$O�Mܰ����	4�l泹Ƴ�V�&�r{��%.ޑ6܀���7T|�sZw��%���N��]�ӱVfح���]���.�N	&�����?���5~�;���@c���K���j藫Ζ[l5&�m=��]�M���vy�8������d�8� �kA{����!��m��p.�,�U���,��8�^������O�2_����:�p}?E0�&��� ]�h���}�ŵ!��܆(����躛�T���O�4~>�uʛ�x�_���A�Ð�8-w?���a���(��N���+U�����Pയ-���[��\J^�|��������r�N�����z������<ꡋ���mnpRo�$��Ғ��'�y,n������c����r��F�	A�k	�j!��b82���,6���e�ֲg��b\��,-6+�%P�^��٣�w�����h2z�ӭC͉q�x_�����z�\]��E*�AȜ�\�p�8��_����w<���bY�v�3�ɦ pJv ���y��8&��{C�J~.aB��eyOd�Vg�T�;\�R���0���Cƺ�@c�/j�vR���~Z"�=��9+B�Zn;��:����ۃ	3fb��범^�|�g�(������I>�IskU�����=�H�����+�8/��_|����e-y��q���������/��$\�4�S����\P������*�������^{�[d�?.�z!�w���Y(uMN-�A��p;�4����>���[��>/�v���$hr�q� �oV��b�h=�D�%������
�] %GO���~�Nmޛ@M�D;��R��P�zi���i><�h9��pF��l���S�����qӡSY�d��I�9q�_J��W0�^�e�qB���b�j���m���3蓗�W;y�́Z�L
���V~����Ŏ
P"\���
A"�'���_N^š=�:͖�����ApY^�&�%oH}뵈�OZ3ǐ� 1ͫ0��� ���ypP5��n%�kra�Q�Ø5��5	����-�+(�72T�
�x�.�,�w ����jR���;�[����H��z?����	G�pݹ���1�t��9��Х(��5٤Y�e�=����Y��b���^�V(�J�I�B��ӻ�Tu2lxs�u1:����E�U���-7���o#�5��*���1��`l�G�����=g�zQ�YL-WC�uz
ooUQ�_EҎ��E �t�T���5a�*ݦ�'u:����j���
*SJ�GyF��U�A��_{�� ��`�WR@3�@��:��廄FU�j��Q���"�o�vs�[<V������&�Ad�*u,�LQ��~�!	�z5���0�19���ȏ��Կ��>s1�!_Z/$�(zq,���S����p:| �����O�Ԓ�)Y.]���G��~M�����k�2��'��������)��BQ� ���\'~�����"���l�����6�O�j�I�~�{Q��DE�      -   s  x����N�@���S�Q$mi-z1A"x+`c�%�%��ww�B��l��&��L�z5߫z���8�T�S�ܯ�I�bL$�s�dmF���ݨ�W���Rm�*FW����%7�#l�TB'�O.�1�g�Z+�b��v��v��S�O�`\d0�\>����I��u2YË�������Q&H�I��J�¸}��=1o?8Su$p�~��g��Kh,����NY�3����t>$YD��@��-�Xf٦�U)�G�������r�t���?T*���_V�n�^����^���v�"vAZ�2y9B��R��)�b�9U��jo+�IOl�np䶜�v �b����G���#�`.I����9����T��8      .      x��][��~��yL!Ѕ��1mnE7��n
�
�G�UȖ!�@��+�y(�٦#y�ƶl~�~�Jη��p�]���n�%��淶?�{����(���O�u��M�㻴4�tL���{�y�f�D�����ݯ��p�8C����*������Á7Yl�k�x��;B��%��
~���ϟ�{ ����)0���J���Ki�rx&�GӒư�	�+���GЙ�klu�Տ�s؞Ȍ3�O��JL=O�P������*|2O���4���+�h*q�:�sb��&9� ߤF��u���h�m�|�䁕��FQ�ƹ4hNV�6Ӯ��Y~�7�`2�?�+� �L�.�N��v���P(��ӈB�+7Y�	2d�8�(�8w ���_�"~��
��Z����0ԇ�2�g�$EEk�er)��4P���[����F<���`�x��.�<o]�/z��4�n�2O%��3�b=��Z��d-�*��H���I1�U�n5��'в�.]:�� A�1�`�-V���byK1J �\�����S@%"�$���e��Y�a.�G%�k�(�8
����8�p�L($X��q�I&�W��c\m�[U���'�� �: ]s ���/C��|������(��2O���\ηP2����@�J`IК�D���.������;!~��ϣ��̥��*eEP�Lͦ�R�u&i ����9قw�,�Y��S=����t1�I�|� `M��CL�I3�r�6P����%�'�z+�⭀�;�;c3�Ek.�d'!LF�4��9[L�/aN��.������ �7f�f?z&!/!"w���D(4b�Dh:�@�ɜ�zA��04�}�i��<�U�bW��$�{,�8��)%G$g��	�$�(�u���x(��J�����)N�U�Mn�V�����jpQ�p)�R�f�P�f����s��a���}9X`lﺿ��+HQ��`�3°�#�>T�@����ׇIV�9�|(�h%Y���Y�VLM�Y�5�0R|�q���_�e1F�j+�>	-��ي+O+�,�:ͼ����*Y�����^&;�-z�߼o�
��>ԗ�P��`�Q1�"xd�Nأ�:͞��Ⱦ�?��7�~��i	0�<���C��d�$5@ğ@3Zp�	���q�׷��C{�̳`�X���ق�4���P;��3���s3S��c�vJ�%�o"�*�qz��:`��*�-�!Hv!@�O3��.�Ǿh�l�F��B$��r��$�Ь�M��]ݜ���p�(��*]��v$�63F��i�^�	��1����Q���?���N��jEcŚ�R(#�I2 @�6�a�jm4�Lx� ĕ$��R���O��B
��t
R�
Ҵ]�Ro�W�FccP����aـ�pޚ~�-��X����4;���a������Yd�� b��R����+�y�%L���s�ա��}�̪b{�O�%�I��_���#�9s � �j ��؀�mןL&6HڵB)?\5R|1nO��D.r��`u�p!�X_͇'i�P7�~�,_1��Qu,PH���4/m�2M<&O	��.wa�k(���I�ٲ��s���7~=��Q�N���K* \� �h&EK�6W���L�w@����7k���&�]��7~��3��qDߵ���� �2�"�d�
S �d�'j���ͱ>4�ҕ����i+�vc[9�k�J!�:�>p����Y��r:]�m3@�E�턔0��v�}��3U2�p�JX׊ͤ���;����f7]׷/�	�q"���y?��e��(�����]C2bk%��Q�L+�S�����<�v�N��Gv{���K(�}ӵ����}�Gc��!��Rz(l����Ak3w6������a;ԗ.���u�\���s �t�(yT���佺��=�\6P
��*�$��sN�xe�%��r`�^M���Z{h��Q���D~�G�?�]�� K�*���!E��Y��_r'��qd�ƿԓ��ʮ���;w�C{���U�4�m�y}EU%����$r�`~hO�Kgp=�HE���p� ��"�Ri�)�5�E��dD�q_�,�B�fb�����yyʌ��L�(�?v�eӟn�$=
��o�9,9��8���L��2��ͩ��1*\�M�m�SsХB$�٨�Q�R �C��ք�ֆB/�I���=�,�/�Ãl�pi������F!���f��P�=��P���RP�~��ʺ9}H�L���!���!��g�"�Ou���R��}x�"�q�3$<x}���wEӁ<�k�>֝I�\OA��#nL�d���s!S9V�
�/�n���$��h��^X��k�z)3���a�3��?�G0�w�Px�s�0�Z�M�x�)Y=J���ԇNdBI���`���V�Z
0�Rp�q��v�u���IS<TW�7-��q����ڪ^��u�#N�|u2_��Jf������֐H�}�<ZW0/� �Ʀ�O�VY�^-�m+�=I|,�x�F����,���qhg�;1倱�y����}���CM}�a ?fv�r���2&)F�<F�0��\]�x6e��@%!r�_�+�P|Sc�6�$"��˃�,��X��
�6�{E�̆I�-y�|OH�h:B���Ho��)���EB���J�̉\���[.n�r�O�0z�M~.u�-SЌ$��v�c��M����U�~����d*�`f{�p���6�8aG*Ԧ3�5CKg	gl���ڮ���=�h$�,����,�ެ42}ρ���Ws��Q��� jpY�!F�&�$�ä����f��`��6�D#d/�`tخ�l��Ҝ��q�����(�r/���{D��"��HD@�SQ~�DI���v�Iy�H��Hժ@����7S����e��qZ-W"�:�1Ѭ+�����J�t�uQv��}�<�|�jͱ�'��?1W ��l�.hF6 ��+��`�s��|/)�T�+����M�F��ly:�&u �,��29X]��bq8-9��-�ٷ7�:��ˑ�x�=�lE�x��g�qil����F�?n7�~<��Pd+�r�J�l��|q`���B�,?��8�q$�P��N��&��q�j/�I9P  ����'F�>��Yz��#��bf�U�|&Rx� YǢ%�㓇���Po�7�`�����J�77�(��#��+��3�Wo���� 9���<HVl��q�n��W�i��)��!��K=MI�X(v��J�|j�GsK�K�n �K�%jo؊��M)+���DEH���A0�O�Q�Y������(�,���2���9#K���^�����(��	�G����&�L�gN��̞�ȟ��|��/�r�S�I�|J��� 4�����Ө����GM�/�Tl�e)'xl$1�m�!F����Sל�>P�A�/�sT��-gz�yJ�<�������f�v��Ԝg�K�����df��Ư��Ur�9����	�))��g
)_���n���s���Z��|�<.*�P]!!ť��A��ӅJ>��T^'_�:0���5L�.KI�ƻ����C�>X8��Z��^lho���|Z�$�.�1�m�YP�`^�o"� ��߿t���*�[��W<�Qʯ���6v0��]^��n������#Ss� k~S)�F���l
6IR-���z��:��SyP����m��y�G���@�	dB�\��gd �fs�� 'n3����d�A��(u�7uh�a�
�D+G�����8e����d�(���G�ކ�P)��8�y��d�]��^8xg��x�u~=�=P�{����K�k�r���R���*3�s��W�K	AvV'p��pm��#Y2��y'I�ϕ����R����J3���9��!�.�`�\�e�nxe)�N�e�E��D��8�ӊ��E���ч%j^gr攰O�eZ� Цw�����z�BH	��+��O�扝c��n�;,ѩ��Y�E�ľX��$?�����a�� z���<�k��z��0�[ N  ��|��kB����
oq٥{����B�&�̳���e����TS�PF�pQ��Ss��x��s%�B�B:֡�3r������|臺e�J$w�����N�隈������H|fwk��]���VNRr�q�J�u?B��Í{psz���,�������8���8!��* '���쐉Ē�΢�$������L �k �����.W�oK�`d�mk�{��ay�`���F��P���-�8�G|i(��	��ѻN�+�x�����I������@l�?�������if�>�nR����k��*�> �X8 {���%sɓr�%B�s�X�q4@��N�Ƨ8�A�=��v��dYZv��I@����ew�Sw��}�%�*7�D���U��ZL��Y6���-�H�"�[|���ΑΜS���ܖ�A��uۆjz����p[�2Ɨ�v2�G�J?]���?Fk�?m��L�ͰF�d���
�z���	m�h�����t��H�]�U��A���->�/�G����	�@�^��yv:��ۚ�U�>�8��W���Q�qIQ�B�cMz^LJ.3�&CX��o��˯      /      x��][���~��yt7����iZ�q�:�&F���J,(Q�t��ߗ;3��(��n�:ycz?���\������9�w�c�Դ_��W��������t��_�o��u�M4�q4=�='�����\���I���I�鹘~���÷���8�p�͙��N�N�f�
'5�e?KT�w���<	�nƉˏW���7b�����t�VԌ���#��9�ܠ���Y�v4��w��_�cwhگ�;�]KK@�4��f��f��a�F�b�J��y���O^�d���k� �K3r	��=7�[
���&�Ъ���p�IP�i1�ZR���KL��q�ܬ��V�,�kE�K���W��J�~%þrC���^iCU_6Թ=��'�ֺV*��|�j�
�D񮰤湪|@�=�v���86�$���k8e"1�;����i�����^0�c?4�sw�T(�Q\����;
IG��@��h��t�H�׌`lW\;����"xG�s�G�X��Ňq޵�,��$�P�Ct�Dt<�+�i�}%�<����^S�f�H�b�~�&&�j�F�¼V��x�C�w'�!�I���b"j��+��N�#
ez�9*�P����D��B�b7���f��ڽ#�0^�K���<�*<�x�(f��e	:2s�=��d����y-�g1���}@���odv����=�_�k��q7�S���i
+sI4RvI	'�r�j��W�wԳ�/����k%���#q7П���d�7�0%1�	�*�)>��-V!��瓸yz�H��Z�^��6��}36���W�b�o�\�b�E�f�>w��oȒ����� ��ep=>ۋ��n����`7�J��܁�)��4�٧@U��+�&OwՄ鮠�$� �@WҀ��b0��(�"�sp������f�5�cl��fӎ�Y#ˌ[.�./����`�i�M8�A�,\0�˴p���^�^�4l�y���yA l��!���(FH|�5���G�&Ä@���BH�i��^�H���W�蝘 a2�pE���S Zxp�{�A�ݫױ]�8u&%�7'"@�!�!��]]axv&��PDM���˩��ZK�|�E��;��t�Č���	��*?LJu�P�i)p��+�_ȈY����&���{Ix��{I��`�O_�k�7csV��I�/@�
�V���w�� �;�H?�S���!��������3Gl�3����r̃.��`�����cw�(T �9,@o��/�N�g�R^-�+�f؊�U` 5qG#�Ԟ8�lH�wf`�7���P��!�C�������4f�ǽ*�	b�'�]Ӟ���p֘U3��4(���g���W������+ �z'$�i<9(��I!-$ώ�
��I8�Dd�\!i�T$5} 
.��fyJ�9ꥁ��%�'i����ٜ/|�<�pË!G	B+
�,�4ysB��������c'Cau�h�+�J�l�(���)R��
�jl4b���W(���s�5j	�u,-}p�L��n��|��P<�P<�:J�|l�9��N&�����]�'
P�fK$��8��W��y!���?5�6_��Uī#�+WǨ$�&Rє��hc�>uZ�*0�+�_Ȼ��}	�q\Ãx�+��0l'�;i$�pb��!��Mr۸u�fU%����xnG���D��]#�o@T�H�DB�%o:p�֎�%֦%nhq��D�|X�,�@���ph���!���A	EZ��ak�N{l�ZF�	�&"'dv�he��I�[jD)oY�y���⭭Fx����yߵ#��	Á?vj}����⯘��Yhj��Sn���@�
V���86���I�<{�c�V8`�e�2��s��� ��mv����"Ƣ ��r\�d�W#� �g*�@�v8OzT��9r�V��$�z(�ZkR&�b�������|��>y���
�T9=N�0���0�@A����^��H깮|�9J�sNV!z=s�8�&c����]w<jL?��uʏj椀��o���#���>"�Ͼ�Γb�'���;<\wh��IΗEÖy}�'�e���5�2��a��5��O؜a$����'������+\����`3C�������f�7�����M��O��g��;U:^lS�Wx�P�iן��k`�F�9�bg����0߈��������[]P���r߲�7�ܳ�-����}�N���ؠf��#�e����|�NқTC���%�=j6�ڂp@d�0�{+��H��x`|��]p<G0 s0���Û����i����Q<��(0�NS4o�E�����45�a/�XSQ����Au�h���n���"F]�?7��YMK���w��H�I�J�4�l)�����uA96���]N^oZy�s̜ʢy88j�e;h�`tO��Go�����NM<�Ȍ�֧��%%�+�����aC�cE�ȏ :�&<�G隮������p�kwQ����e6)(Ad8����/�A큂Ζq��ߩV���[ȇ��a~�l��tN�QcG1�G�l�􈒸��
�	t^��w}��	;j�������hSA���� ����Ln�IK��,\�x}B-k@
�9eۗ	����6���ٜ*�bF��xH����!�f�ׇ�PJ�Cb(��A 6��M��u�T�2\"���H�f���������'�+�� K
�l�޶ݰ=4Rz�Q�5����'�Զ��S��m�(��W��4vx������of��]���HGs&�-�Gk�t���[�%�P2�Q�c+���:�y����{-ᙵ����aI������u��A��,���ߍf��|f�cq�lԤKu5��<��(J%P ��ޕ#�^I�Eg��ɕ�\�G���s�4�,��w���W*[�6��;� �b|P�J&�cVJ,}�Yy�۝&�ܺdN�A3�ߺ��9ۆ��6)Wkp=����8��{�Y����e�Fk�A�b(�z+v@O�iO����[Y�u<�!�89lV�ޡ����ji� ���<��Bpe%z\rI@
���n�����@
ba�f�*sC�*�y�^w�%�-m�v��1�wZ�\H ���T����hάZ�79ٶ�x	����%$���Ugz���\e��l5>�a�R�qB�{M1@�����%j� ��=.�L��� Ļv��(���E��3'�|�]Vޚ�F�9����B�������L��k��)t'���a�q�t�@�D{0$Ce�E�$����B�p�ܒP���كZ�h��� �Ng�=���3s��9�,�wX*�&���<6��4� �`� w�y���1���U>V悀Oд�x�T
	�j�ݰ1�'��
�@���f�����M�r.Z:[wU;M��1����\�����I�K���ڋ�����L��� y���� C�ؾm+�6�ʡKQ��d}X�
�;l�;S~���V�@�j���Y��o�Ч����*�[-�vb�dF����̋�#��A��n�꾐]�:������M�r7�1��v����d�}
(q��U���Ca�������
ˣ��a��C�v��FA�F�)���`-r�Vj��������W��L�mT�I=*�dZ���w�f!���CSZt��:C�C����?�|D���r�����3v7E�
�%�d��Eٜ�]��y��w���o����#,$��QE���b��:��4lv��r����Lz��֦�z��v�EҮ�5�{-W�#����i�K.�*e��v�uc<��Jx��f���#��f��-��:6=n����^o�d��5�x7&�]�jN7 �F��',����v�<=pԃ"���K.��8O~c�UOl�tK&��υ�-���1���5�B��;#z���#��S�ꕯHQC�F�T�
�N�ؙ�k O�Q�� �U�C�qຆ�%�!}����)uM��B�4GŞ�K�!w�]���vj�?�NJh��ׄ&�.�8*�@0e�h�h���ZRQ&����8x,��|{�;m���� p  P8L^_֮\�������xx,�2��V'(1����AU���s&'
���f+��I�Lf�J<�L"�M��E�˕{��UM#��@32����b���]-fN3�V�0��k���
�٣t�B��pUO��
H ���!����Sx�Q�� �d�g,_�lw�~𸗸�`CX�E���3o�슜���|�͇�~:5���ˀ{�����P�� �(�,P:M�xZ#p�,��jyRх�]�������0?�cs�W�*|1�h�k�C��&�����)c���{��p+�iQ��bfK$O~&�����*�`sD�����h�'��
�$�
-l����=r}����T�q�9��hyR]Ѐ��B�3��=J1�̜>Y�v�Wx���x�,�]��à��'
�kPR9%���p-�&�V����q�v�z) ��/5I₃�z5)���l;̓G���v,�x�#��9,���p����M�Ѷ�F�� ���0����{�QT���>���y��c��[-�T�����j��%���Q�2��u<_����s�]^f7s�S,'�5�z&�@�S&�+'����j3cx ���o�T\�      0      x��]ێ�6}���y� ��%?�Lf'�̥�=,�4�[kk![�l�߯�"�C��Lӝ�Ql7K$�r�T���������n^�ի�����揶߾�5zG7ћ4y�Q>=�������o��W��*�_��2_]�[�;�{9~ɆϦ�f%_�1�9�e�|N�x9=G��q%��xz�b�36�S+e�s4.L!�����$��������D}�y�w;9�b>t��U��FL���cK���0˔����|ū��~ݶۺy}ߌc�u�M
X59$��猞S1��DE�x�b!�������##1/���fjY§ �����L�u���*9!uMM%"3�_�z4��4�4�q�].H���'��D*&���P�6��}�*1��{T 6�I"��S�l9�Aj�0�R$������y�g���Ŋ`v�x�o��AX�f��dɺ#��ؘe�l� �.��I}W���I�]=����2Scr�LC��9��ҫT����]��X/��Ʌ�ѳ��qbrl���iX/��j����ú�����&�ƀ��,`�2c/ɋ�{D��Շ�4��Dƽ���0���M���_����n6��J����T Eצ�d2X1t���f���HlFA�H2Pi�S�Z��|��aݹ<˵
%��hA�&����s�}�>�~��i�ն�ܕ�سlr�W-p	�T�"��!r�����z��3A�S�G��˅آ4�)?$D%�D&��_��/���b��~d0���F}<���Zr�u��@,*��̝���v9�KS�X{lb����)��J7��§~[�]�mv���\!���o�aK{�5��_���ѳ��zӓ]efur��:��'%XMn1��Iz�sz��e�)j��f
9Y�a��GB\)��G���ye��BC��p��ٴ�r���r18��p:G��֓an��0�4�As*�d�ي��r���/���+�u�sŉ{Vd�ʋጔW��C;s�nW�v�ʙ�ӆ��2��Ka.	x6�w]�k{O�DXLBR�f�����2��
�_���q���_9�7���K��'5�H��DHۜ��Wj(�6���$BT�V��Nr�9,�r۹���:�	hDd��nl��&7�D�����m`���{k��c7�GZ����.�7��Y���
��J�Z ��X��)*���v��A��������Lx/�i��<j!���j��62�>5��L;���VF��ը�W��V�'`��Z��c�n��Fe\�쥙�Q	Fb@?yf��ױ]N���{�f
4��ؒ�	=T�&g@B�/ʈ���xɇ����N����)���%i'��د�ޘ��öV+7�U$�չVn�Wi���=���y!�D.#L�o��^�%�ē��	H����TQ�����O�*(�{B(�f�?ioS��A��]V��b*cI���W�� ���]�����ò�s)�]ӳ��
ب�^�3�hVF=������R���I���o*�������ym��T���i��04(�;��Ʃ�o��g[�|p��g�T�#Ț X�-���k(K��8xCn��H�ϕ��<�%�I@�F��w s,	��L�AQ���>Gd>TAz�,�q*k	�a}���3TXR�-�J�"���#�T/,S�	�|m�z�3o�yZ��"p���/��r�p���
3&3yWH�3�7��p�_%��j�q��_�!v��U��ehw{�g�ȝa�|�����*�$��Lir�w�8�e��~}<'Rǫb���t�@/b;F؂&w׌�~�M��ՂG^�Q��Љ����)�e��î��]�U�Vn�Zi�������X���}�3:Tg)�<L�t�ޠ�(w���0*?WkE+��o2�)�Y崙���G���$v�qXn!W�햊a��M.@�
�2�C0�ZDz&��2�J=�o(��V�N�~��J�����W�+�2̑����@g����0�`�V-na���H� $Dϥ�ME��~�kE]{�I��U�(�G
�ҕ�
Lb���x�.�1�	� C�5Jq�r�B]�+�@���B�}�l�Ɂn��A
�2dgt%K��)J5O!��KCE@��'Gߜ�|� �3S���VL=	d��8a�l^E>����*��*�i� ����6;��ޞ�N<�Q���R8��جĴFE0A	PA���A8K��t�D:N��A���ef���ƫz�iT>5��j���GL
M*,aV��Q)�F�"�o�}�8�ϊA^���Z�}7��a��3QQW�����K�+�19��b@���2]i�%Ϳ��l�_{�
9}t34��o|l���R�7̈́��ÒMr-PTD�N�K
�7�r@e?�u�sˈA]-S�y�MkS���kŮ�3e�����&���,��&���Ņ<S�v��_�G���	9L��,8�{"�n�m��[���zیǥg��fV�J��d� #,r(�>m3�h�'T�{���40�d~�k���eQ�<�Z�L����B�J{S��LB�j�$��n���,{â��%�_tP�h!$V�&�f1h׎��~|r�pDX�@�X��DB���y(���pP����1��p!��Ƕ��>��TSj��vC��K���<�\a�3� �%;��@�$gXGM���fTT��b�pPx��r�"�J�</�M!ɳHE�04�Z Їfd��q��I�?���h�p/Yݘ�#3c�9��ɱ��N%��]�d�Q��,��]�d�E*Y�ʄ���R��P$-�m����wvsB�6��`�B�_�C��}��ܧj倠�)%�^��.nN��o{/	.�_�9�@bLbS���Ѱ�u�;�.PZ,N��ܩG���h�-I) �X2�����؄E�k?����ƳS��aZP��4)wd⎍
����òߝ�q+�C�x���9S�L*��;������4j�������A���o��l��-��Ű��f��CN ���a�v�9>��B�LeJ �1��(˂B� Q�9]օ	��8���v���)�����x]��)p�� 4]bޖ��U�����o�biu��dN�,�PH��XO q�O=y�98��8�#�jٿ�ۥO	ht��4ሐ(b���(�[b�O쮺�}�o6�4��G6�`!��b�J�3��3��M�Tu'�q�3u�~;�� �L�f�c��#"8>���P�F�`�©��(d�B#Gj���s����a_^p�l����[&���91�+�7kX�����I�X^���Y))�:+7;��輦1."�;�b�q�'���E5"u�&�Pܙ�9�"�n��f�=�
d5�&˩>n�ذS��8؂���V�$�T
�%y���^$M��È�����b�<�G6S8�kwp)l�K�>��Cǂ�>{8;��%�8��e7!ʥO	�UT�p!��<���M�4�p�V>�@�u�)�r`J�5a��P���x�2�`�r�}6\�v�R�S�|3Q��72|�1�WcR.�����j��^�R�<��I��(��U��
w�fP?�}�Nv�>X����`Y��-�{ZU��{�Wur[b�V�j���U�l�����%��	�.Y��'1��T$��v;��T�`fܓ
����]�@��3 �Jx����h���F�N�9������|��p��������!'T'�,�p�
Yl��7�"Ǫ}�\�c>�=X���:�Oa9D�>�5+в��hy?B�����]���Y��g3���FVJ�^�K�$LZ�d�{��B�`�y_ǅXdw�b ٪�����!(���ÖW���+��x�ŮƳ9c~�4g|׬�OFf�F�;��|�yy����tM?�v,>yZ	I�p�@����ݤ�_o;~���c�Zd؏�m�?ɑ2@Q	;��Dj]�������~>�LLܰ
-e9܎ae����%��Ft`��uN��tfT&�k��O��,�K��f#��]2�r����D-}n
~�j?E�V����aӊ�|ۓ`��u�}��q��4�}W�x��{+�n���a��M���[:\.g����9H�c��t�j� �  �M
L��s+^��ױ���c�p�=?�=.�"�=�/T�
�#g�V̩ ���&�n�a�t�엖t��o]9��`b��z�ۡ뇱�w��r�
��B"�9:|�k���y��� 1�_��z�$�e_Ch�v�E}0Iu'd9�Yh.��ޜ���37�{��>,'w�'+���.K:�
L@�vI,�%^ވՌʿ�o�u�E,�_h	�����/��蠧y�Ŕ���xA��s��eg�>��R������9�Ob=�̱����L��#ܤ�o͐��i2jSn���N�c<�j >��sd�1pU+�h�� ��"� {�T�c�P���]���p�]u�:q�]�b/���
��U�ᶋ��j�K瀞7����/������o�C���,�����~��%�.=<1��RPb��Lhb���� c2��\��g�7m�r�aQϹ�`t�	Ņ�#u�Ԝ<W��^��C�6Ϲ��ltvD�P���7WWW����Z      1   !   x�(J�M�I�����r����%p�=... ��            x������ � �             x������ � �         R  x���[��0���U���å����H���-nJ`F��	�C� �[q���Mm��_�������3��d�"���{�GY R�T�Ԍ�� �u�'�P+ �5�?Ö@�N��Q����zQ���gj��莰ꏱh���h����p�����(J0�e�Mͅs�HN=� RD+ x\�f������S��O�z�����8ǻ�������z�'��e�{��0�Dd~�F1�F}%<��|�m&4�el������g0�O�`���b��#��V��z��Պ�N��[�u�N�e_�/���,X��x����SEp���S�gt���U��GS��Օm�vW���ɒȑ<4�n6?GB��f �u��M�����P]Ӿ3[F����
��5*K6�;",w�c����"7:2�;*(m����h�+3K�­3(�E  K6֜UD��4�����@s���`�f�٘-�-��1��*6�;�����YXى�L��ȯ�DB���uʼ]��ߦ���0�QY�Մ����^���jHdt9lE~?$��!�K�z�jT�Gc��c��O' ��Y;�m�!U(�8���wq��l���+:���KJ�KX�      "   �   x�e��
�@@���-܅2���(%��B�ALiy���>����SP}��'�ژ�FE�	pz�'ch����M3UtV~Jk�;8��wa�����H����vIp�>vz�@��H
HD�)�It�P���d��I�#�x�"��0ʫ��eW���U�$�U1�ݿL���N�p�A�S7�      $      x������ � �      &      x������ � �      3   u  x��Z�n�6}V�"��.t!u�7�`[$[#v�(���R�JIAԯ�P���5�� ��`��r�F:Hyy��y;iEm�V�B�� �B?d�����oC�˾��s�8�ӛ ei��6�{Y�v ض� �V6' 0aceY	�|��iY)'��Ϊgy�ZX�*�t��]�>,��}��Q���ֲ��`EYN:�}/���N(k�����T�;�Lar�8���cU�25 C ���i)�,<��]-����iT(ߔn�k�l���Ί� w�B��?��!PC�V���#��Y���}a�	���	)N�I�Q�kbM[XHW�~���:�Ȥs)W��SR.JP��.�j(#���)�6�{&�d(��8�=%N<�<�j��XS�ۛ�"�����&�`�Yw$ΰ �y�8�"�#���u! � ��ފ|k4��dC�ى�Kw�(�����)e��H&	ҪV�]._�~����#�Q9����GY��
�N�/k�㾕�!EB�w��������;u��?%_�*�뵴���h�ύ�;�^�	m��	ƶ5�����	®�}Ӑ��'����~������i��S���/I<C��-�?�U-�4q8d��������x��ӝ���������6c���J��a�(i3K��Tn��`GB�!C0��f�kbL�_���%�ڏi1L��C���\)�ҾQ5�:�,�1��8Ҵ�lK�.�M��ܠ���y��4�Y������M8�S
�1X�l�ܷ� .���0�#�n���Ţ=P�^�jS,�wR�Ie��?3������I�֝����fx$D�3��7�z��V�v2�}6 �ת�,ݼ
x��q�_��>�������@)���_�$T�bl�h/H��dU���0���1&���D
F�`ܹ�]�M��GP`��P��u��J��3hA��x�-zk�;;6n�-!� ti�~B�Y<���'�1��/�p(�`$qU|)�����tZ�A�7��rS.��ڧ.�jA�&��m�p"ہ�����q1p`i<��|+�at� ��jر:�4���k�h��-�zx��4T��ωr~X�a��3L��;������x���5?b�0�r>OR@8�%��B��j��%¨�~RC�H�Y3��)�`T�Lo ,��N}(�È�Y4�����2E�
�h���l�m��0���w� `��	Q�cx��8yB��ӣ"��'��O�x�aص�ߺ�v��.:xz	4~ ��I�lz�*ai�3���?x����!$�KT�C%�FM��BW�wZQ.C�������������l����0��K/�졇��t��S�O��2?�ٜ�-P[S�S#��'��sv��m͐$[�[`���7�UgW�g�Z\�>�Z�[�_Ƒ0c�A�"�ag�vL�1�_�_FY�s�MǾ���RT��)) � >pN��U�m�AO9�*��Dkj��v3҂����
�e�x�ʦ)��^��K��׾�����KU���]��;�������R���q0�P��؝�p*��`�#�3�π���e?�v1��$�`A�H1�I���NX��/�NGI�;���777��J_i      (      x������ � �         �   x�M�K�0D��0U��{�n�CT��"���Rv�c���G��B����ZV�I�r�0v�H�.]T%��q)�+[&=
��=���s6�!{
��x��yl������<�Ռ���.	9�	�c�U�n�v����лj(�`|s\�����ɭ(����ݯ�u���_6         O  x���ۮ�0E��W�J��0�R�r��X�V����m�z��� !3��{����Fۍ�m�� ��v��i
$H�
{���G¸��R�0�x}_��,U�Z�}P��O%�Q���/�Q�޶������6��kEZBb��>�N�zt}�ύ���ڻ::�U2�Kf>���Y.�M3Z��i�ƶ&����j�AH�	�B��KP�g��6c\,��t�;�n�$*��N}4Xߺ��	�[�G7��į^����XY��)�G�暷��ϡ�G�3%=r?�0nL�TT� ]���D�Sb\�65�V���J��ߓ���y�\ۀ�s���yo��4�d�އZ�}�ukC0���"�2��ʗ�H>��+I}��3S�ȨrA��.����0T͓W+�4D��|����P0�[�5πϪ��*�ƕ��F(�����@\�-�r�٫��M���U�㞙�1] \�q$��]mR��aj�T��+$�GTBȜ:dK��gӺ������S�"\}B�9��80�I�����{`B��(c����[�p5������k������+ZVD	�x���q������      )   
  x���n�0  �g���/5�����m�@a*�CT��P,��;��h:�	�H�����
9��ز{�ټ�SR-�+7�
�	�[ƄH��]��z�趽�v�$�v"Z_լ���5���ǳ�\��7	h�N<�nJ@�^�S��]�eCʷ�V��P�J�g�����Ѝ�>�Kx�~|NҍRq��ٹЌF���?:��7A/�N`�����K��g��?W���xV�>�!Y�� Z/�8�v�b�-���դ���0�d�^�      5   h  x�͛]o�6���_�����wnҵC�Ԁ�^
��,)H2���C*֗��EIF� 0�>"�sx�P�$�6bϤ�1��^ ?�~���=��r�����B.��/6�(s�x`uë׋G%��O~�Ƛ��|������͢Q��d������7�G^�7�&Kd)Y�Q�����M�?�JP6E�cQfǚI�S�i�V߭ P����X�I����/���><�o�%��'oc�{9�9c.R/��wQ7�"�D�?�WAH|Mt�J=>�V��/=��<�3$�����g����Z�/�0�����W��_R�y��	5�;%Uu���4B3�QKi���]���M��
Rl�TΥ�U�Fi��N�q���ѱI��TUp~ya�"�\jλC]
��	~���_��(N�k;��$���)+��<Wb�L~�O-1����/�)��@][��d�u%I�R�uI���j��4�%k�kJ241HW�d�� ]{���漦$���fJ24�Ȼey.�<���s̻�x�F��N=	^���=�ƀ��{V��f"i���J6\ʮhW�%��[xI	`މ�;�'�4�4/���ݟ!��B�m����UnσaE84��oՖ����8Շfb���m�ϩ$M���i��Q��t	@�+~�ʑϱdR/��:��O�h���g7�	"C�{	�Q�Z�F ��M���t�KAw�Cp6�!HO7�ǻ��'u��َQ�R�oo�[����|บ�(�f	0vJ�K��݇~z�qT������h���:G���P�}���#M@��A}���O`kI�gsZ7�i�Ǯ��� �sk{ɾxn{7}�՝�i���D��;2��B�l��=OKm�a~�i͐�#���V�V;B���f���j lq��N
��,���%]�膠��UB�X�/_g!�@�(ʺ[��9pO������ˬ/�I0K�.b�Xw�̦�,�AI�e��&]���"�!�{(3�ʢ>��U���j73LE3}�Y�Mk�kV�'����r�^c��ʆ�B}�r,��g8>�bX�����)��~�Ay�*�n'euj"á����$�ϏO�~�n���_��x�s��T	�ux���=B�K�xusU<����gy�㍗7W��X�-6���0����!^�|�rطO��!�i�x����eZ\�!9�1��h��X���� ��C	ϠtI�o�8�}�p�����f?k�a��t���ٮSh�h��R�f�h���T������m�[˝���$B��c�昫�z07��ĸm�n;8-�@X�F#����e��Q:4�R/�E�����A�(�Lɮn�:b�x��z�	�����,���=�����o.�Xh�1�Q����W��us�H��k�3�
�s�Vzυ�K���[�/Ӡ�R��d]����	.F+u��	Lct���aGf���Bwv�f�X���N~���c��LO-�9����68�T�άV�1��)�����N���&ٜ�	mw�rx���|��B2F/^��_�9h�%�k�%/&u��`M�\�s;C霐g�^���q�%s��Ǯ+1�k���s��w���Ɏ�j�/�����Y�1��pU��y�V���nnn���q      <   z   x��N�1�M1;`��5ql�u,��%�hz��^���& �Xt%�
�����+��qL�ѱc���^
�XbT�i��bf_aO,fRb�НMџ��X,�"��T��v��ݗ�<��05      7      x�͝�r�6��;O�8�KR��?��gcϨFNNjk��`
�����Xy���D\��$��JUB:c�F���h4�$NgW���jM��,�zb�j0�KZ^y�_��]=��&���WT���&�u�����
|��j�;�����ɯoi[6~���Y��
_@5���gZ����|��,�m���z[K��IQ�%�(����D�0c�`��Bz��@*F+�!%�z �{A�b�Od��H�;eK�5y�gR�i)Hop�F�0�����������N"��LHuMR��f�i��+m��Qr�Ꞔ��j(���,L�B��.KĈ��|�	�׈q��H:�W�ܢv���y'3x>���?ikp��3��P�&9bU[K�~�"��|$�b4�v����{g�_���d4���$U�Qu�; �����M�|�Q��Q�i���.U!qI��Ŭ�όۦAl��5�'�V�;ЯH��5)�f��/ikwjł��
�����yxN�`~o8�C��8P�06h�I�0B�=Jr�Zo��H�A� �W�ǶW�(UA�j�<F�a0�?���H%�T��kR�E.�_eї٠,��2Zf�� b�~Y�4�K��P,�&l�`�B�#᾵����t"��7���Nl��m�0��L>XA��ġUM�'5�QѬ���Yp��u�'[���I���O!ڙ��1�3<	�{��kR�{�y��F�]�kR�{օ�Z5��ȟ���?�)<�i��_yM��j&���8X�̒O���x�B1�e�*.�z�O$�޴C��bh3�G�|�c 	T�9bB$uC�m0���#e<�c�8���e�D���0����qF�W�2��!|7T�8cr�ǉ�Ϙ����ܷK�Ā�¥2�EMj�t�v[�'3q�Ҍw,�p|��Y ��^w� ��' Wf_��u�%�����~���J�Y"łs��b�N{���"��r�H��]@����Ɖ�!��#�O�'"��9�>�~�y.�l��Γv[�>�����h�f��x��Iu+�d%��ݾDZ�x|OK%y�����O�m�j]�Wlr=�U��i�|%�I��aŶti�R���������-3�<�Č�eo�`���L=�	�A~oW�.�7����b��k���:�����?Q�-Y���8�K�b�������X�Sa�a��YN�=��:��_���iO#�g��l����o\��Q��2x�hU���+?J�~�m1lQߵ|��yў��SW2�7�, �74��9|�Z�bAa�]�{Rqx=�L��m%����)h-�W����Y�WO�S9��#<�����*s"�~I�&W�wf̉Kn�"<Ǻx=Pj ]2s���7��{*�5]�>��.�����Xq��esW�#M�����	���
��<CH���Gz4���a�|Nt���K�^�<��D��%G��?
���я�5;�"��DbJ�i�ؒ��( �F�ܮ�-E�@�X&����/�)d��'Ü?FVx ko��.���޴3<�}RA�r����F����|�9�#d�_����i֌t�� �K\6�e7��6��D��nJ��"����I5���J��<Ғ6������+�+���8��e�za�м+W�C�&)�@y��C���]��UX:*�`v���lo���B�=�p3b���@v�0�������)�24(�!)˱�L�+;QE&�<����A����yQM�]燶�oT�TkİG:#��|XbcX�D1x�\3U�ׄ�K�[#}⎆�}��o#�<��D��5t���ӭ�\0�R��)�{E���v
s�n]�ؖ�]�{�*����N:H�R1�L�jE�oa/��kS3pe	Es����@�B�F<͓>Úe����lB�3��q8���@�K���I��<,�]�%��� Rq��qD��H�c���&-�af:�;�kq��c& �>l��	<1$��Z����H���NΜ^��=K}'f9q�=�0���w�6S���K?��o�<K��<���kL��K�Tc��.@2�崀/Nf��!��.�i�7Qv�f�B5`$m-?'�Q�@4�Jz.μ;��3-����%*
�l�h��j�݈��Nl�q`af��>�\(J�o��_�O~�F�T�wP��e]Qd�-��j"<�#-�^Knr���S�7OϸG�#39���lT��J�Ӆ!!Bτؠ�ƀ�}���4�
��1�X} 9(��$�H	gX1�H� 5g����I"�d�pC��m�؄^�/z�\)��'�M�Тe�P�]�-v�A�,Ib���F;���2��P�_F�#�ȑq^9��8�+�C/3�p�� ���=���xAC��ʴ�rZ9�B)�0��s��p�� �$��(�b�����g��!����7��PJnj�9Rp	�N�Wh�e^��1�+��n��t8��������(�]�F/�Qs)�{;�5��\�~y�n�u��(��F�b�I"s�-���5.�P��m��f��cu��<o���� ��n�r�x�.�_o��fe��7��lxL��f�d^cqd�m#�٭�L�H�qb����W.�r���l��+X4b�U�7q���L<�ц��R	�����8]�����
��o�-���O,z[�(����ޔj0��0�[qKW��H0��	�̻M%�G8�� pt�#�-$�G8�Āx�G8�Ԡ�?�g&���K<��G�r"��
p�.���.��*��x�~�Y�+��q�È�Z-
�F�y"�G�a�%�Aabf�#���@IL7c�gQh�"�c%Ida�=V��"�?~S�Ii��&�)gEց���S�$�������4�K#�7����١��Dͻ�q����9�]t�6ʅ����Ѯ���8�� q� �����[)a��4�u	$O��@y�Õ���Z�K|͒NHI�]�uR0��@��V��]��|�����4�Nsv��03��`�`B��0��	�$b%<����?��YN�Op���XL�W��Zu?r �@u��zt��$�EW��O5���a�į.�=uU�2H4|����HM���#��-`@�t�������#�r��k@'�b����n��x��g�n����pfm�,�8�e�7����>�[
 S��f�-�Na��:
�a�}�x�]d�������v|ٝoA���0ārU's$��"T��QS��� Hu��_��1n#�
R'b�Nҍ�5c�te�ǧu[�0���^P��P�������7�U��iƽX�E�<�{�;=�v�^�h�5⌼z��<f����H���j��
D�|$\��V=�skxE�ssy�5$� @�!w�Oկ��0BY�8R�^k1!�86,�E@P4]Z������V"�� S,-D 0OŰ�����IK�<���c���q��̚�!P�^Y 3�a�f�B`�����/՚,I���6��!�{2�L��{Z�Y� �ٝ��P����Y���au�P"��{<�j�sb`A�<S7�h,mCE&�H��Z�X�U��ׁN��@��3����p���dP[?���wx��Lp��r�i�d&ϸ�L�0�L����`R�d�����F&���f��	
V{�@�P�D�I4�?f�	4��/�� 2z"���y�i��
�c��q�p�d��ֺ��tf�q� x�R����L[��8��IRY�D�m�7݌/p+����x�(T�4�IA6N�P���"c�����pi�����ykp���` ��̌4,�`�j�=��xc�K�����S^<f��[��#��#-4I"�+7�<o��2 �� z����'9ݠ�M_j&rδۦ�9��\���7� 1������І����r#��@���|[p��ȋM�׻�n���]6��An�py����� ���zUlE���/`�L�����!��K������jgi ���R��ϘV�\��H"��p �n }�F�A�A��l>a�	���w/@����7���)�Ҽyn���e� �  ;���M74T�w�z��3m��������f��$�ո9�4��͆��8,�M�47���;�oZ�mw�0_*��bD��׈�5�(��&�0�5_ĮćJB��.���y��":x�?+���(����a�,���{|�K9N�Lr��5*Ϛ�A��-V��q����2� ������ϴ-Ж�4�`v�@B�i���(0y��<Z6�r��f�'����b`8��#k�w���!��u�DÛ�lz�8�ם]��pEA�=����E��~'����9�Mѐ�� C��FAz��\��h�ʟDA���{:�����r�y��������m��� ����Yp�0F*�X���5��B�ٳ�-�a�B�m�}��7l��υڜpx��y�����t�����Zw�׸$��+`��tv�e��(�{~�K�C�|F��~��E��A7��*�q����V<�F.�Q��Ӻ',o���t���=�OuCF�އ��q��@Di��lNr�=�#���]^ 
���G���c���Gp����w�n�\��v�����P	Vl���5z^Rw":n�cu�;n�*�} ��%Y2d��#C������3�[,ZjA�v���\LfCٕ�8�R�yھ�XN��0�򒝭��V0٢�/�>��"�|��m�\A�-�P���lW������Q������,����O��A{�VH�Hd֔1~@�Zӕ���D	m��e�ʑE��5��5^#@��I�x/����F*\sİb�����6#>��$�o����5���m3`ħ'��d�[q��?�ȟ��P��q��hT��M��pF R��'R�Tq�{�[�B0�-Ξ�Kپ�4�P�m[)���M-\r�88�ŶU����M�-�ls,��r���E��ָ4�ap��D��
�"�a�	0�(A��z������I��Uڙ�M��Q�e+|FG�sf:�,�a��>�`޹��q�v&{%:�*�;I_�+;�$���v�Z����\��:F�fU���д�rq�1I��XAj�+\�1R/2��S�i)�h������L�~�@�k`3-�?���&ɤ	��|���}�T�#� �hfP�/��\��p�3i(��S�|;݄^���ds/��#�K�
L��m y��菮~YY�����q_�~���E�ǅʳؖh�F8���3�؟���E��gn�X�O�4�/���nDE.)�i^`Ɔf��m�b]t�ٹ�+9�%[M��Ja}E��>�[ ��i�<Ra�Z��e�z%�T؁0_Ӻ?y�� �x�9��Y�oF򐅕�ULK{��Ny���1t�*�\X��i�LâCP�_�4;�a���f,���,������ȳ:݃���֨t`g~	4�O ̒Ų��*ĥ݂N>�zg�&ɢ��+����=�m�I������f6])���z�P����=@'L��#���"�_�;�5�f��7�=�55Z� ��%�iő�=b�����Uᶦ̺D�����C�T��*�#)p8�L�X���^�.�l��9���͆2��䉈.h�}�9��K��v�K2���a� q̽�q�a�@+cf�+� ��e#d�
8N}s������К^�'�-�(����:���s����}WM��7��L/��Q`��F|\I�K�tJ�H�#C�WUj������ƥ<pP�Q(�\2{ m�+�Va4*� <m1���� J�y�)aI�y� �%��4_W&	6�2�<�<rrA6j;8�Q��;z`D����J���捿w@������S�l�x�<.�tќj5�y��͟&�~3���~ӧ��d��G�=����̈́l�#'��<��	FL6���I�K�f>��1iz,��<�)	��f;-���l���������|�	�5�;!�0��f�鉎�q���#�rkǣ�C�����"����y	DL��ig��u|�-�}]t|���݀E*��t��J�Dp_VQj!X�<�"�8y�Z�>q��c&k+�������Blz�������u3��p�#&[��R��:B�mw)�M�(��`R�Qb�|@�z�?�/����`�o-sT�G�A�Q^'J+�=��T��G�/,J�}�gw3n�&l�C�� ���2�d�f�#)��V$w��d3����8u��
)2���gG(6ͳp�K���4�]a`n�FP.�X�E�Se2��W\�M�����%��^TD�xR�ƕKKL��p8dIg�+F�h�!+Zʮ�}��)I,�HƉ4�\m
弧��a�8	��=���q)8_��Zb��E��P��X��#�z�?���+u�{���0�C��?P�Z\¯5a���ق�?�|t�c�F �5襯���z_�`�����X�F�zZ1\bp�TV�,r�pw$�<���]�@e�P�j,u�gSN�7�O"y��8s��ՋރG֍��F��<G�"�U�h����Aeӷ
�"c"�kq\vW}WY.�BF(�aw�0�LC�E���wA���X>�m-ߜ�,NS�r�#b. �X���O�]`��~�4��3jD�S�h��1b�G
�ԚI~5_�Q������û��f��4<p���g���;_�r�4=Ge	�BO��	�q$�P��sQ%�&�Zj�X�����	5s,3o�*�N�8Ԍ򂖔Ѣ}q
��_6ό���J����a��h�w�X��S�[�g�n�؜T�i_���a�R�rqp�͖��<��MY��B�|�d(a��	N��l7��1��(<��?E�3(
U���cE�2����T��B�5��B���n(�8i��iݖ���7���-��bI�Q$�t���=��̥�o���A�"�� �=�zK�� ���j���4�Y�^��ơ��|��2�����u[�8��nE�Zѕre����� �����W�qbQa0��y��s*�&.�۰ᷴiT{g�Ð�O�&��~��a�\��P.��		Ö�=��c�֩_�'�%�ۍ!d��0�?-	�h��F&�����n�(1��Oܫ��r�*��&[\�"��P�c�d&M��@h.���F�3����!�Ojm�����7�H�a���v����Y�������a����)tj�h��*�G26I`�!�d�EuX��ǧ���J�߁yL�-�2�R�k��a��#�v��R�jw%Z�P������b����dX녲v�3�`/t��ư�;�v��1��?��[3b�S,3����.1#%x��43��B�Ӡf��'��g��g�a��p��+?\�u~Y>q��g��_X-J�F& �i&�yX��h:�O�Y3y�âB�.x�V��������#��?�d�s^����v�� '����L��ù]c"�.T&VAD9o%�}=��Ɓ�$
��T&s|��S�/�L��6�����w߶eI�GD���xE���hO�~2������=� ţ�Z>q᠇z�+�vN�m-:�p��bf�FB5b+n�r�FU`��X����m���ۍ<P��)?IH>��>a����fã�F�g�t�G\�� F+;8�j[������:�����i5�L)g�Y��ӿ����Ȫ�'hI�w�3y�oO���B\7��|~&��q�����D+,"�]9��_�$�0`C��@�W��@��0�M�-�}(aS'S)Z�s�<��#,,V�L�,��ߓ����ky�~s<����(�r��#J��C]��u$JZ��� 9�elb�~�D��t��Q�DJ�1�1�}�Fm�4�����7�q`�]�|��43��.c��4�.c��HF�1`!�Ѹ�0�i�-]ƀ�LC}��0�i�-]�`Rb�k���lKL{}���i��"L�'�LpM��7j�~�c* %��62�$�����#�H�����WL�����%~C��`u./<�r���Ju�\��{ie.��Օ�OЊyd�cu&SO'��P���~3�ŀ��o?�����`�      >   [   x�u�Y
�0D�'��f�r�c�آ%��1��8lH=x�L"9��Os�t��&��[5#mP���7U���W�Xk��eZC�u�σ�.�y      @   �  x�Œώ�0�ϓ�����$Ƕ,�XUj����xi!#7���$�Qq�2�-�o�o,,�!��P:�"W�:]�`^+!@�Ҁ��`nK�.�Vqm�hH�d��6|;���yl�*�c̷��oہ�n}߇.4��l�����_O��F�Z^���j���Yz���`�p���E�G�ƚ��Q�J"�)���@����jd(�;����q��^�j{�A�+2D�U�A��ܑ]F���ݕ7�7�wۤS��mC�<E�d��g���x&��0��"�l���b�K�KTƬ�P�i<��SR2j`�m`���nj&\.�KZ^��Yz�%���/�c�VW�������?�X���z�D�$��?Wv������g�xh���">��=�C�L�,}9������@Z��]9D�NHU�z8�� mj��E|1Y�����ϲ�;�-�      9   �   x��4��445�4�K-�Tp���KO,I���OI-2<RS8}��S\+S�,���-�Woh�i�ih�钚Z �Pb�i�a`pnbN�R#�B��6�4ڎC!�Qk�i�i	į֌Ӕp`g��X� �i      ;   �  x��][s�8~�?`��2o���zg�W��O]��T+$F@o��~%l���qnXL?�L:����;GG�gy�
TpV�����ov`�5��G��"`ݐ�$,��#Z��&̮2l/Q^Plߠ���w{��O���f�#�O��Kq�b�
��w�+g�������������Z��5f�hP.+��[������+�� _竼�M�K0v��C��;�Kט�UfA���/�2/�_Q̈��� ��(�0b�hE�u��4|�i�2�om�QH�Ԭķ�H�U��Z޴<(�w �r�Q��$F�X���I@5m �9�Yށ�z�ߩ!i]q��H�������x%�;�	.��%���R��BP�8+2�xa�XCW��H�0 �I��Ӻ�M4�Q.�ZB�Bh�v��zapz��~_�׸�j��H:�	�:�L�Ǩ@pN<�{�� ����%���I�mg�-݈l��o�ܛ�{� �N�h�'�����/p{ٴ}_Z��+KS��r���*}��ʄ,f&�h'�+�j$/��q���K�x��ߋCݲ�*?���;��Z󬻉�р2L9S��A���$�KVe���3I�$*ζm۲ʐ�3k��%�v����f����˚�Q��X�T�����K�F�{�ah�w\]��t-ar @�k�J9���$b�;������Ӻi�=h�7O�*���2�#�K���v	��e�cQ�[��Ht�z�֯���	�K��۞cMi�U{�U/��c�I2������"#� ��ո�g�-�\�+��zzw���J�p3~�?��⯚���"v��(�W��s�z�m���;�J����0����� �ú�8�<�+'7����t��MY��bB	r�a������Lx��\�pQ,D}�KԬ���:�P���;?/դQ+w�>�$fa��&cỲ���m�w���a���|��]���5v�a{�]d36��֜�?��_do�q/קA�&�o���1У�4��4�ω�u����׸ 	��&}���곗�*]��O�\o(5���{Ý�����ܞ��f�)��"�6��ڊ�+�k񿼛D�l��MI
�)�|�p�@J���j_͜�n{�S�����_pN�����q8C��Gǯ��ֳ��0�+	4����!��hjn�W�ו�zޜ5W|ǥl���K���Xd���1
Տ�Ӊ�^1�0��Dt�#��9:y<'B�B�lƆ�������es�����p�QV�V�/#fl'|	�sA.2�F��m��Q�-�Ҿ&�P,Q	����E�����N�?��C��� >Q
�aw\$�()D�d�,G�|�4�{[�1�:޵�Ϟ�5�X�|�����cL�t�h���O�PmA#A�nލ���%�[C��b��e��CW}�h�ո42��A�_�kܾ���M��m���$�zv��֣���(����9V�[����u�s�}[ge��5S�FZw��e���a(.��z��\]�퐬z�Iҭ7���1�B�XW5��e��pm:j���_��j��t���}ˬYo��𓱿�{�kbxd�$0�"M �G&<�G����`,�X?hjxڢ������q��-�1�ӛ� Q�}ը�nÈQ�G��(�4� �����dң�Jכęh��tް?�h�랡��N�&tB�M�LT2z�1럟`*�����7�d.v�It��ߒH�����dW�W.�bS)������r����u~Лśd&�@��e��h@7�2���d��a��&�D"�K[��VM��OZup5��h�o��{�4��2�A�5I���Gy�KU�`1'�{M���u֨[�웝o�l�#O/�������~��ǥ>�A�e��"\��0����9���UE��ԙH7��"}Cm/Lx��xG����d~Ԍ	}�<��$f<G��_1/"k�'�QS]`�e��7�Q�9P�nŻ@��Mn6�pۤjAVr.��,��`����g�\����l��M֗=����˱�98������sO�@1x�^˒����Aݰ@)��d@J��Aӭ���z��,nP��N| VH��`f����"�d\������s�1J}�@}��1G�����o�0o�*=�5�e��UL������&�z0�Y~��c��&ʋҳK�Q!M=�K�M���ֿ��@����p@lD��Z����vi������&nY���Ç���d�     