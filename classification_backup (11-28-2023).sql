PGDMP  "                
    {            classification    16.0    16.0 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            �           1262    92296    classification    DATABASE     �   CREATE DATABASE classification WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'English_Philippines.1252';
    DROP DATABASE classification;
                postgres    false                        2615    92297    knowledge_base    SCHEMA        CREATE SCHEMA knowledge_base;
    DROP SCHEMA knowledge_base;
                postgres    false                        2615    2200    public    SCHEMA     2   -- *not* creating schema, since initdb creates it
 2   -- *not* dropping schema, since initdb creates it
                postgres    false            �           0    0    SCHEMA public    COMMENT         COMMENT ON SCHEMA public IS '';
                   postgres    false    6            �           0    0    SCHEMA public    ACL     Q   REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;
                   postgres    false    6            	           1255    92298 f   calculate_fish_ratios(integer, numeric, numeric, numeric, numeric, numeric, numeric, numeric, numeric) 	   PROCEDURE     �  CREATE PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric)
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
       public          postgres    false    6            �           0    0 �   PROCEDURE calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric)    ACL     �  GRANT ALL ON PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric) TO lab_examiner;
GRANT ALL ON PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric) TO research_assistant;
GRANT ALL ON PROCEDURE public.calculate_fish_ratios(IN sample_no integer, IN bd numeric, IN bl numeric, IN pdl numeric, IN hl numeric, IN snl numeric, IN ed numeric, IN pal numeric, IN vafl numeric) TO study_leader;
          public          postgres    false    265            �            1255    92299    count_all_samples()    FUNCTION     �   CREATE FUNCTION public.count_all_samples() RETURNS integer
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
       public          postgres    false    6            �           0    0    FUNCTION count_all_samples()    ACL     �   GRANT ALL ON FUNCTION public.count_all_samples() TO lab_examiner;
GRANT ALL ON FUNCTION public.count_all_samples() TO research_assistant;
GRANT ALL ON FUNCTION public.count_all_samples() TO study_leader;
          public          postgres    false    244            �            1255    92300    get_next_mdecision_no()    FUNCTION     #  CREATE FUNCTION public.get_next_mdecision_no() RETURNS integer
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
       public          postgres    false    6                       1255    100079 1   insert_flexion_family_scorecard(integer, integer) 	   PROCEDURE     N  CREATE PROCEDURE public.insert_flexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer)
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
       public          postgres    false    6            �            1255    100083 *   insert_flexion_family_scorecard_function()    FUNCTION     �   CREATE FUNCTION public.insert_flexion_family_scorecard_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.insert_flexion_family_scorecard(NEW.sample_no, NEW.fgroup_no);
    RETURN NEW;
END;
$$;
 A   DROP FUNCTION public.insert_flexion_family_scorecard_function();
       public          postgres    false    6            
           1255    100093    insert_genus_scorecard()    FUNCTION     	  CREATE FUNCTION public.insert_genus_scorecard() RETURNS trigger
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
       public          postgres    false    6                       1255    100081 5   insert_postflexion_family_scorecard(integer, integer) 	   PROCEDURE     [  CREATE PROCEDURE public.insert_postflexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer)
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
       public          postgres    false    6            �            1255    100087 .   insert_postflexion_family_scorecard_function()    FUNCTION     �   CREATE FUNCTION public.insert_postflexion_family_scorecard_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.insert_postflexion_family_scorecard(NEW.sample_no, NEW.fgroup_no);
    RETURN NEW;
END;
$$;
 E   DROP FUNCTION public.insert_postflexion_family_scorecard_function();
       public          postgres    false    6                       1255    100080 4   insert_preflexion_family_scorecard(integer, integer) 	   PROCEDURE     X  CREATE PROCEDURE public.insert_preflexion_family_scorecard(IN p_sample_no integer, IN p_fgroup_no integer)
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
       public          postgres    false    6            �            1255    100085 -   insert_preflexion_family_scorecard_function()    FUNCTION     �   CREATE FUNCTION public.insert_preflexion_family_scorecard_function() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    CALL public.insert_preflexion_family_scorecard(NEW.sample_no, NEW.fgroup_no);
    RETURN NEW;
END;
$$;
 D   DROP FUNCTION public.insert_preflexion_family_scorecard_function();
       public          postgres    false    6                       1255    92304 $   insert_shape_characteristic_result()    FUNCTION     �  CREATE FUNCTION public.insert_shape_characteristic_result() RETURNS trigger
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
       public          postgres    false    6                       1255    100108    insert_summary_ranking()    FUNCTION     �  CREATE FUNCTION public.insert_summary_ranking() RETURNS trigger
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
       public          postgres    false    6                       1255    92306 !   insert_to_classification_result()    FUNCTION     �  CREATE FUNCTION public.insert_to_classification_result() RETURNS trigger
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
       public          postgres    false    6            �            1255    92307    sample_master_fish_ratio()    FUNCTION     �  CREATE FUNCTION public.sample_master_fish_ratio() RETURNS trigger
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
       public          postgres    false    6            �           0    0 #   FUNCTION sample_master_fish_ratio()    ACL     �   GRANT ALL ON FUNCTION public.sample_master_fish_ratio() TO lab_examiner;
GRANT ALL ON FUNCTION public.sample_master_fish_ratio() TO research_assistant;
GRANT ALL ON FUNCTION public.sample_master_fish_ratio() TO study_leader;
          public          postgres    false    247            �            1255    92308 !   sample_master_meristic_decision()    FUNCTION     +  CREATE FUNCTION public.sample_master_meristic_decision() RETURNS trigger
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
       public          postgres    false    6            �           0    0 *   FUNCTION sample_master_meristic_decision()    ACL     �   GRANT ALL ON FUNCTION public.sample_master_meristic_decision() TO lab_examiner;
GRANT ALL ON FUNCTION public.sample_master_meristic_decision() TO research_assistant;
GRANT ALL ON FUNCTION public.sample_master_meristic_decision() TO study_leader;
          public          postgres    false    248            �            1255    92309 ,   set_shape_characteristic_result_row_number()    FUNCTION       CREATE FUNCTION public.set_shape_characteristic_result_row_number() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Set the result_id to the next value from the sequence
    NEW.result_id := nextval('shape_characteristic_result_seq');
    RETURN NEW;
END;
$$;
 C   DROP FUNCTION public.set_shape_characteristic_result_row_number();
       public          postgres    false    6            �            1255    92310    update_classification_result()    FUNCTION     /  CREATE FUNCTION public.update_classification_result() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE public.classification_result
    SET rank = NEW.rank
    WHERE ffamily_name = NEW.ffamily_name AND fgenus_name = NEW.fgenus_name AND sample_no = NEW.sample_no;
    RETURN NEW;
END;
$$;
 5   DROP FUNCTION public.update_classification_result();
       public          postgres    false    6                       1255    92311    update_genus_remarks()    FUNCTION     -  CREATE FUNCTION public.update_genus_remarks() RETURNS trigger
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
       public          postgres    false    6                       1255    100119    update_group_decision()    FUNCTION     &�  CREATE FUNCTION public.update_group_decision() RETURNS trigger
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
       public          postgres    false    6                       1255    92314    update_morphometric_remarks()    FUNCTION     
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
       public          postgres    false    6                       1255    92315 $   update_shape_characteristic_result()    FUNCTION     �  CREATE FUNCTION public.update_shape_characteristic_result() RETURNS trigger
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
       public          postgres    false    6                       1255    100109 )   update_summary_ranking_meristic_remarks()    FUNCTION     O  CREATE FUNCTION public.update_summary_ranking_meristic_remarks() RETURNS trigger
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
       public          postgres    false    6                       1255    100110 -   update_summary_ranking_morphometric_remarks()    FUNCTION     �  CREATE FUNCTION public.update_summary_ranking_morphometric_remarks() RETURNS trigger
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
       public          postgres    false    6                       1255    100111     update_summary_ranking_remarks()    FUNCTION     �  CREATE FUNCTION public.update_summary_ranking_remarks() RETURNS trigger
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
       public          postgres    false    6            �            1259    92319    family_genus    TABLE     9  CREATE TABLE knowledge_base.family_genus (
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
       knowledge_base         heap    postgres    false    5            �            1259    92324    family_group    TABLE     �   CREATE TABLE knowledge_base.family_group (
    fgroup_no integer NOT NULL,
    ffamily_name character varying(45) NOT NULL,
    common_names character varying(200)
);
 (   DROP TABLE knowledge_base.family_group;
       knowledge_base         heap    postgres    false    5            �            1259    92327    ffamily_names    TABLE     �   CREATE TABLE knowledge_base.ffamily_names (
    ffamily_name character varying(45) NOT NULL,
    common_names character varying(200)
);
 )   DROP TABLE knowledge_base.ffamily_names;
       knowledge_base         heap    postgres    false    5            �            1259    92333 
   fish_group    TABLE     �   CREATE TABLE knowledge_base.fish_group (
    fgroup_no integer NOT NULL,
    "BD/BL_ratio" numrange,
    condition character varying(100),
    sub_condition character varying(100),
    "PAL/BL_ratio" numrange
);
 &   DROP TABLE knowledge_base.fish_group;
       knowledge_base         heap    postgres    false    5            �            1259    92338    flexion_stage    TABLE     K  CREATE TABLE knowledge_base.flexion_stage (
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
       knowledge_base         heap    postgres    false    5            �            1259    92343    postflexion_stage    TABLE     O  CREATE TABLE knowledge_base.postflexion_stage (
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
       knowledge_base         heap    postgres    false    5            �            1259    92348    preflexion_stage    TABLE     N  CREATE TABLE knowledge_base.preflexion_stage (
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
       knowledge_base         heap    postgres    false    5            �            1259    92353    stages    TABLE     V   CREATE TABLE knowledge_base.stages (
    stage_name character varying(50) NOT NULL
);
 "   DROP TABLE knowledge_base.stages;
       knowledge_base         heap    postgres    false    5            �            1259    92356    classification_result_id_seq    SEQUENCE     �   CREATE SEQUENCE public.classification_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 3   DROP SEQUENCE public.classification_result_id_seq;
       public          postgres    false    6            �            1259    92357    classification_result    TABLE     M  CREATE TABLE public.classification_result (
    classification_result_id integer DEFAULT nextval('public.classification_result_id_seq'::regclass) NOT NULL,
    sample_no integer,
    fgroup_no integer,
    ffamily_name character varying(45),
    fgenus_name character varying(45) DEFAULT NULL::character varying,
    rank integer
);
 )   DROP TABLE public.classification_result;
       public         heap    postgres    false    224    6            �           0    0    TABLE classification_result    ACL       GRANT SELECT,INSERT,UPDATE ON TABLE public.classification_result TO lab_examiner;
GRANT SELECT,DELETE,UPDATE ON TABLE public.classification_result TO research_assistant;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.classification_result TO study_leader;
          public          postgres    false    225            �            1259    100078 "   family_scorecard_fscorecard_no_seq    SEQUENCE     �   CREATE SEQUENCE public.family_scorecard_fscorecard_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 9   DROP SEQUENCE public.family_scorecard_fscorecard_no_seq;
       public          postgres    false    6            �            1259    92369    family_scorecard    TABLE     �  CREATE TABLE public.family_scorecard (
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
    kbs_remarks character varying(150)
);
 $   DROP TABLE public.family_scorecard;
       public         heap    postgres    false    239    6            �            1259    100091 %   genus_scorecard_genusscorecard_no_seq    SEQUENCE     �   CREATE SEQUENCE public.genus_scorecard_genusscorecard_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 <   DROP SEQUENCE public.genus_scorecard_genusscorecard_no_seq;
       public          postgres    false    6            �            1259    92363    genus_scorecard    TABLE     F  CREATE TABLE public.genus_scorecard (
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
    kbs_remarks character varying(150)
);
 #   DROP TABLE public.genus_scorecard;
       public         heap    postgres    false    240    6            �            1259    92373    shape_characteristic_result_seq    SEQUENCE     �   CREATE SEQUENCE public.shape_characteristic_result_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 6   DROP SEQUENCE public.shape_characteristic_result_seq;
       public          postgres    false    6            �            1259    92374    shape_characteristic_result    TABLE     m  CREATE TABLE public.shape_characteristic_result (
    result_id integer DEFAULT COALESCE(nextval('public.shape_characteristic_result_seq'::regclass), (1)::bigint) NOT NULL,
    sample_no integer NOT NULL,
    fgroup_no integer,
    bd_characteristic character varying(20),
    hl_characteristic character varying(20),
    ed_characteristic character varying(20)
);
 /   DROP TABLE public.shape_characteristic_result;
       public         heap    postgres    false    228    6            �           0    0 !   TABLE shape_characteristic_result    ACL     �   GRANT SELECT,INSERT ON TABLE public.shape_characteristic_result TO lab_examiner;
GRANT SELECT,INSERT ON TABLE public.shape_characteristic_result TO research_assistant;
GRANT SELECT,INSERT ON TABLE public.shape_characteristic_result TO study_leader;
          public          postgres    false    229            �            1259    100106 &   summary_ranking_summary_ranking_no_seq    SEQUENCE     �   CREATE SEQUENCE public.summary_ranking_summary_ranking_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 =   DROP SEQUENCE public.summary_ranking_summary_ranking_no_seq;
       public          postgres    false    6            �            1259    92379    summary_ranking    TABLE     |  CREATE TABLE public.summary_ranking (
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
       public         heap    postgres    false    242    6            �            1259    92386 6   classification_and_characteristic_complete_result_view    VIEW     �  CREATE VIEW public.classification_and_characteristic_complete_result_view AS
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
       public          postgres    false    227    227    227    229    229    229    229    230    230    230    230    230    225    225    225    225    225    225    226    226    226    226    226    226    226    226    226    227    227    227    227    227    227    6            �            1259    92391 >   classification_and_characteristic_complete_result_with_remarks    VIEW     z  CREATE VIEW public.classification_and_characteristic_complete_result_with_remarks AS
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
       public          postgres    false    227    226    226    225    225    225    225    225    229    229    229    229    226    227    227    227    227    230    230    230    230    230    227    227    227    225    227    226    226    226    226    226    226    230    230    230    230    6            �            1259    92396 -   classification_and_characteristic_result_view    VIEW       CREATE VIEW public.classification_and_characteristic_result_view AS
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
       public          postgres    false    225    225    225    225    225    225    229    229    229    229    230    230    230    230    230    6            �            1259    92401 
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
       public         heap    postgres    false    6            �           0    0    TABLE fish_ratio    ACL     �   GRANT SELECT,INSERT ON TABLE public.fish_ratio TO research_assistant;
GRANT SELECT,INSERT,UPDATE ON TABLE public.fish_ratio TO lab_examiner;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.fish_ratio TO study_leader;
          public          postgres    false    234            �            1259    100096 !   group_scorecard_gscorecard_no_seq    SEQUENCE     �   CREATE SEQUENCE public.group_scorecard_gscorecard_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 8   DROP SEQUENCE public.group_scorecard_gscorecard_no_seq;
       public          postgres    false    6            �            1259    92412    group_decision    TABLE     �  CREATE TABLE public.group_decision (
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
       public         heap    postgres    false    241    6            �            1259    92416    sample_master    TABLE     �  CREATE TABLE public.sample_master (
    sample_no integer NOT NULL,
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
       public         heap    postgres    false    6            �           0    0    TABLE sample_master    ACL     �   GRANT SELECT,INSERT,UPDATE ON TABLE public.sample_master TO research_assistant;
GRANT SELECT,INSERT ON TABLE public.sample_master TO lab_examiner;
GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.sample_master TO study_leader;
          public          postgres    false    236            �            1259    92428    sample_no_seq    SEQUENCE     v   CREATE SEQUENCE public.sample_no_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.sample_no_seq;
       public          postgres    false    6            �            1259    92429    sample_view    VIEW     6  CREATE VIEW public.sample_view AS
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
       public          postgres    false    236    236    236    236    236    236    236    236    236    236    236    236    236    236    236    236    236    236    6            �          0    92319    family_genus 
   TABLE DATA           �   COPY knowledge_base.family_genus (fgenus_name, ffamily_name, dorsal_range, anal_range, pectoral_range, pelvic_range, caudal_range, vertebrae_range) FROM stdin;
    knowledge_base          postgres    false    216   {{      �          0    92324    family_group 
   TABLE DATA           U   COPY knowledge_base.family_group (fgroup_no, ffamily_name, common_names) FROM stdin;
    knowledge_base          postgres    false    217   ȴ      �          0    92327    ffamily_names 
   TABLE DATA           K   COPY knowledge_base.ffamily_names (ffamily_name, common_names) FROM stdin;
    knowledge_base          postgres    false    218   ��      �          0    92333 
   fish_group 
   TABLE DATA           p   COPY knowledge_base.fish_group (fgroup_no, "BD/BL_ratio", condition, sub_condition, "PAL/BL_ratio") FROM stdin;
    knowledge_base          postgres    false    219   �      �          0    92338    flexion_stage 
   TABLE DATA           �   COPY knowledge_base.flexion_stage (ffamily_name, fgroup_no, stage_name, bd_range, ed_range, hl_range, pdl_range, snl_range, pal_range, vafl_range) FROM stdin;
    knowledge_base          postgres    false    220   ��      �          0    92343    postflexion_stage 
   TABLE DATA           �   COPY knowledge_base.postflexion_stage (ffamily_name, fgroup_no, stage_name, bd_range, ed_range, hl_range, pdl_range, snl_range, pal_range, vafl_range) FROM stdin;
    knowledge_base          postgres    false    221   ��      �          0    92348    preflexion_stage 
   TABLE DATA           �   COPY knowledge_base.preflexion_stage (ffamily_name, fgroup_no, stage_name, bd_range, ed_range, hl_range, pdl_range, snl_range, pal_range, vafl_range) FROM stdin;
    knowledge_base          postgres    false    222   y�      �          0    92353    stages 
   TABLE DATA           4   COPY knowledge_base.stages (stage_name) FROM stdin;
    knowledge_base          postgres    false    223   |       �          0    92357    classification_result 
   TABLE DATA           �   COPY public.classification_result (classification_result_id, sample_no, fgroup_no, ffamily_name, fgenus_name, rank) FROM stdin;
    public          postgres    false    225   �       �          0    92369    family_scorecard 
   TABLE DATA           �   COPY public.family_scorecard (fscorecard_no, sample_no, ffamily_name, bd_score, ed_score, hl_score, pdl_score, snl_score, pal_score, vafl_score, sample_remarks, kbs_remarks) FROM stdin;
    public          postgres    false    227   _      �          0    92401 
   fish_ratio 
   TABLE DATA           �   COPY public.fish_ratio (sample_no, "BD/BL_ratio", "PDL/BL_ratio", "HL/BL_ratio", "SnL/BL_ratio", "ED/BL_ratio", "PAL/BL_ratio", "VAFL/BL_ratio") FROM stdin;
    public          postgres    false    234   �      �          0    92363    genus_scorecard 
   TABLE DATA           �   COPY public.genus_scorecard (genus_scorecard_no, sample_no, ffamily_name, fgenus_name, dorsal_count_score, anal_count_score, pectoral_count_score, caudal_count_score, vertebrae_count_score, pelvic_count_score, sample_remarks, kbs_remarks) FROM stdin;
    public          postgres    false    226   ,      �          0    92412    group_decision 
   TABLE DATA           �   COPY public.group_decision (gdecision_no, sample_no, fgroup_no, very_elongate, elongate, moderate, deep, very_deep, small_head, moderate_head, large_head, small_eye, moderate_eye, large_eye) FROM stdin;
    public          postgres    false    235   *      �          0    92416    sample_master 
   TABLE DATA           "  COPY public.sample_master (sample_no, assessor_name, date_collected, date_measured, location_code, plankton_net_type, bl, pdl, hl, snl, ed, bd, pal, vafl, dorsal_count, anal_count, pectoral_count, pelvic_count, caudal_count, vertebrae_count, stage_name, margin_no, description) FROM stdin;
    public          postgres    false    236   u*      �          0    92374    shape_characteristic_result 
   TABLE DATA           �   COPY public.shape_characteristic_result (result_id, sample_no, fgroup_no, bd_characteristic, hl_characteristic, ed_characteristic) FROM stdin;
    public          postgres    false    229   ,      �          0    92379    summary_ranking 
   TABLE DATA              COPY public.summary_ranking (summary_ranking_no, sample_no, ffamily_name, fgenus_name, meristic_sum, morphometric_sum, combined_scores, meristic_sample_remarks, meristic_kbs_remarks, morphometric_sample_remarks, morphometric_kbs_remarks, rank) FROM stdin;
    public          postgres    false    230   �,      �           0    0    classification_result_id_seq    SEQUENCE SET     N   SELECT pg_catalog.setval('public.classification_result_id_seq', 15434, true);
          public          postgres    false    224            �           0    0 "   family_scorecard_fscorecard_no_seq    SEQUENCE SET     R   SELECT pg_catalog.setval('public.family_scorecard_fscorecard_no_seq', 958, true);
          public          postgres    false    239            �           0    0 %   genus_scorecard_genusscorecard_no_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public.genus_scorecard_genusscorecard_no_seq', 4419, true);
          public          postgres    false    240            �           0    0 !   group_scorecard_gscorecard_no_seq    SEQUENCE SET     P   SELECT pg_catalog.setval('public.group_scorecard_gscorecard_no_seq', 47, true);
          public          postgres    false    241            �           0    0    sample_no_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.sample_no_seq', 100, false);
          public          postgres    false    237            �           0    0    shape_characteristic_result_seq    SEQUENCE SET     O   SELECT pg_catalog.setval('public.shape_characteristic_result_seq', 745, true);
          public          postgres    false    228            �           0    0 &   summary_ranking_summary_ranking_no_seq    SEQUENCE SET     V   SELECT pg_catalog.setval('public.summary_ranking_summary_ranking_no_seq', 394, true);
          public          postgres    false    242            �           2606    92434    family_genus family_genus_pkey 
   CONSTRAINT     m   ALTER TABLE ONLY knowledge_base.family_genus
    ADD CONSTRAINT family_genus_pkey PRIMARY KEY (fgenus_name);
 P   ALTER TABLE ONLY knowledge_base.family_genus DROP CONSTRAINT family_genus_pkey;
       knowledge_base            postgres    false    216            �           2606    92436 ,   family_group ffamily_name_and_fgroup_no_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_group
    ADD CONSTRAINT ffamily_name_and_fgroup_no_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 ^   ALTER TABLE ONLY knowledge_base.family_group DROP CONSTRAINT ffamily_name_and_fgroup_no_pkey;
       knowledge_base            postgres    false    217    217            �           2606    92438 1   flexion_stage ffamily_name_fgroup_no_flexion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.flexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_flexion_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 c   ALTER TABLE ONLY knowledge_base.flexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_flexion_pkey;
       knowledge_base            postgres    false    220    220            �           2606    92440 9   postflexion_stage ffamily_name_fgroup_no_postflexion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.postflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_postflexion_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 k   ALTER TABLE ONLY knowledge_base.postflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_postflexion_pkey;
       knowledge_base            postgres    false    221    221            �           2606    92442 7   preflexion_stage ffamily_name_fgroup_no_preflexion_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.preflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_preflexion_pkey PRIMARY KEY (ffamily_name, fgroup_no);
 i   ALTER TABLE ONLY knowledge_base.preflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_preflexion_pkey;
       knowledge_base            postgres    false    222    222            �           2606    92444 -   ffamily_names ffamily_names_ffamily_name_pkey 
   CONSTRAINT     }   ALTER TABLE ONLY knowledge_base.ffamily_names
    ADD CONSTRAINT ffamily_names_ffamily_name_pkey PRIMARY KEY (ffamily_name);
 _   ALTER TABLE ONLY knowledge_base.ffamily_names DROP CONSTRAINT ffamily_names_ffamily_name_pkey;
       knowledge_base            postgres    false    218            �           2606    92448    fish_group fish_group_pkey 
   CONSTRAINT     g   ALTER TABLE ONLY knowledge_base.fish_group
    ADD CONSTRAINT fish_group_pkey PRIMARY KEY (fgroup_no);
 L   ALTER TABLE ONLY knowledge_base.fish_group DROP CONSTRAINT fish_group_pkey;
       knowledge_base            postgres    false    219            �           2606    92450    stages stages_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY knowledge_base.stages
    ADD CONSTRAINT stages_pkey PRIMARY KEY (stage_name);
 D   ALTER TABLE ONLY knowledge_base.stages DROP CONSTRAINT stages_pkey;
       knowledge_base            postgres    false    223            �           2606    92452 0   classification_result classification_result_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.classification_result
    ADD CONSTRAINT classification_result_pkey PRIMARY KEY (classification_result_id);
 Z   ALTER TABLE ONLY public.classification_result DROP CONSTRAINT classification_result_pkey;
       public            postgres    false    225            �           2606    92460 &   family_scorecard family_scorecard_pkey 
   CONSTRAINT     o   ALTER TABLE ONLY public.family_scorecard
    ADD CONSTRAINT family_scorecard_pkey PRIMARY KEY (fscorecard_no);
 P   ALTER TABLE ONLY public.family_scorecard DROP CONSTRAINT family_scorecard_pkey;
       public            postgres    false    227            �           2606    92454    fish_ratio fish_ratio_pkey 
   CONSTRAINT     _   ALTER TABLE ONLY public.fish_ratio
    ADD CONSTRAINT fish_ratio_pkey PRIMARY KEY (sample_no);
 D   ALTER TABLE ONLY public.fish_ratio DROP CONSTRAINT fish_ratio_pkey;
       public            postgres    false    234            �           2606    92456 $   genus_scorecard genus_scorecard_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.genus_scorecard
    ADD CONSTRAINT genus_scorecard_pkey PRIMARY KEY (genus_scorecard_no);
 N   ALTER TABLE ONLY public.genus_scorecard DROP CONSTRAINT genus_scorecard_pkey;
       public            postgres    false    226            �           2606    92458 #   group_decision group_scorecard_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.group_decision
    ADD CONSTRAINT group_scorecard_pkey PRIMARY KEY (gdecision_no);
 M   ALTER TABLE ONLY public.group_decision DROP CONSTRAINT group_scorecard_pkey;
       public            postgres    false    235            �           2606    92462     sample_master sample_master_pkey 
   CONSTRAINT     e   ALTER TABLE ONLY public.sample_master
    ADD CONSTRAINT sample_master_pkey PRIMARY KEY (sample_no);
 J   ALTER TABLE ONLY public.sample_master DROP CONSTRAINT sample_master_pkey;
       public            postgres    false    236            �           2606    92464 <   shape_characteristic_result shape_characteristic_result_pkey 
   CONSTRAINT     �   ALTER TABLE ONLY public.shape_characteristic_result
    ADD CONSTRAINT shape_characteristic_result_pkey PRIMARY KEY (result_id);
 f   ALTER TABLE ONLY public.shape_characteristic_result DROP CONSTRAINT shape_characteristic_result_pkey;
       public            postgres    false    229            �           2606    92466    summary_ranking summary_pkey 
   CONSTRAINT     j   ALTER TABLE ONLY public.summary_ranking
    ADD CONSTRAINT summary_pkey PRIMARY KEY (summary_ranking_no);
 F   ALTER TABLE ONLY public.summary_ranking DROP CONSTRAINT summary_pkey;
       public            postgres    false    230                       2620    92467 "   sample_master calculate_fish_ratio    TRIGGER     �   CREATE TRIGGER calculate_fish_ratio AFTER INSERT ON public.sample_master FOR EACH ROW EXECUTE FUNCTION public.sample_master_fish_ratio();
 ;   DROP TRIGGER calculate_fish_ratio ON public.sample_master;
       public          postgres    false    247    236                       2620    100114 .   genus_scorecard insert_summary_ranking_trigger    TRIGGER     �   CREATE TRIGGER insert_summary_ranking_trigger AFTER INSERT ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.insert_summary_ranking();
 G   DROP TRIGGER insert_summary_ranking_trigger ON public.genus_scorecard;
       public          postgres    false    276    226                       2620    92469 1   summary_ranking trig_insert_classification_result    TRIGGER     �   CREATE TRIGGER trig_insert_classification_result AFTER INSERT ON public.summary_ranking FOR EACH ROW EXECUTE FUNCTION public.insert_to_classification_result();
 J   DROP TRIGGER trig_insert_classification_result ON public.summary_ranking;
       public          postgres    false    230    263                       2620    100084 3   group_decision trig_insert_flexion_family_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_flexion_family_scorecard AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_flexion_family_scorecard_function();
 L   DROP TRIGGER trig_insert_flexion_family_scorecard ON public.group_decision;
       public          postgres    false    235    249            
           2620    100094 ,   family_scorecard trig_insert_genus_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_genus_scorecard AFTER INSERT ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.insert_genus_scorecard();
 E   DROP TRIGGER trig_insert_genus_scorecard ON public.family_scorecard;
       public          postgres    false    227    266                       2620    100088 7   group_decision trig_insert_postflexion_family_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_postflexion_family_scorecard AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_postflexion_family_scorecard_function();
 P   DROP TRIGGER trig_insert_postflexion_family_scorecard ON public.group_decision;
       public          postgres    false    251    235                       2620    100086 6   group_decision trig_insert_preflexion_family_scorecard    TRIGGER     �   CREATE TRIGGER trig_insert_preflexion_family_scorecard AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_preflexion_family_scorecard_function();
 O   DROP TRIGGER trig_insert_preflexion_family_scorecard ON public.group_decision;
       public          postgres    false    250    235                       2620    92472 6   group_decision trig_insert_shape_characteristic_result    TRIGGER     �   CREATE TRIGGER trig_insert_shape_characteristic_result AFTER INSERT ON public.group_decision FOR EACH ROW EXECUTE FUNCTION public.insert_shape_characteristic_result();
 O   DROP TRIGGER trig_insert_shape_characteristic_result ON public.group_decision;
       public          postgres    false    235    277                       2620    92473 1   summary_ranking trig_update_classification_result    TRIGGER     �   CREATE TRIGGER trig_update_classification_result AFTER UPDATE ON public.summary_ranking FOR EACH ROW EXECUTE FUNCTION public.update_classification_result();
 J   DROP TRIGGER trig_update_classification_result ON public.summary_ranking;
       public          postgres    false    246    230                       2620    100121 +   sample_master trigger_update_group_decision    TRIGGER     �   CREATE TRIGGER trigger_update_group_decision AFTER INSERT ON public.sample_master FOR EACH ROW EXECUTE FUNCTION public.update_group_decision();
 D   DROP TRIGGER trigger_update_group_decision ON public.sample_master;
       public          postgres    false    236    275                       2620    92475 ,   genus_scorecard update_genus_remarks_trigger    TRIGGER     �   CREATE TRIGGER update_genus_remarks_trigger AFTER INSERT ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_genus_remarks();
 E   DROP TRIGGER update_genus_remarks_trigger ON public.genus_scorecard;
       public          postgres    false    272    226                       2620    92476 4   family_scorecard update_morphometric_remarks_trigger    TRIGGER     �   CREATE TRIGGER update_morphometric_remarks_trigger AFTER INSERT ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_morphometric_remarks();
 M   DROP TRIGGER update_morphometric_remarks_trigger ON public.family_scorecard;
       public          postgres    false    227    270                       2620    100117 N   family_scorecard update_morphometric_summary_ranking_morphometric_remarks_trig    TRIGGER     �   CREATE TRIGGER update_morphometric_summary_ranking_morphometric_remarks_trig AFTER UPDATE ON public.family_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_summary_ranking_morphometric_remarks();
 g   DROP TRIGGER update_morphometric_summary_ranking_morphometric_remarks_trig ON public.family_scorecard;
       public          postgres    false    273    227            	           2620    100116 A   genus_scorecard update_summary_scorecard_meristic_remarks_trigger    TRIGGER     �   CREATE TRIGGER update_summary_scorecard_meristic_remarks_trigger AFTER UPDATE ON public.genus_scorecard FOR EACH ROW EXECUTE FUNCTION public.update_summary_ranking_meristic_remarks();
 Z   DROP TRIGGER update_summary_scorecard_meristic_remarks_trigger ON public.genus_scorecard;
       public          postgres    false    226    271            �           2606    92479 )   family_genus ffamily_name_family_genus_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_genus
    ADD CONSTRAINT ffamily_name_family_genus_fk FOREIGN KEY (ffamily_name) REFERENCES knowledge_base.ffamily_names(ffamily_name) ON UPDATE CASCADE ON DELETE CASCADE;
 [   ALTER TABLE ONLY knowledge_base.family_genus DROP CONSTRAINT ffamily_name_family_genus_fk;
       knowledge_base          postgres    false    216    218    4825            �           2606    92484 *   family_group ffamily_name_ffamily_names_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_group
    ADD CONSTRAINT ffamily_name_ffamily_names_fk FOREIGN KEY (ffamily_name) REFERENCES knowledge_base.ffamily_names(ffamily_name) ON UPDATE CASCADE ON DELETE CASCADE;
 \   ALTER TABLE ONLY knowledge_base.family_group DROP CONSTRAINT ffamily_name_ffamily_names_fk;
       knowledge_base          postgres    false    218    217    4825            �           2606    92489 /   flexion_stage ffamily_name_fgroup_no_flexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.flexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_flexion_fk FOREIGN KEY (ffamily_name, fgroup_no) REFERENCES knowledge_base.family_group(ffamily_name, fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 a   ALTER TABLE ONLY knowledge_base.flexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_flexion_fk;
       knowledge_base          postgres    false    4823    217    217    220    220            �           2606    92494 7   postflexion_stage ffamily_name_fgroup_no_postflexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.postflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_postflexion_fk FOREIGN KEY (ffamily_name, fgroup_no) REFERENCES knowledge_base.family_group(ffamily_name, fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 i   ALTER TABLE ONLY knowledge_base.postflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_postflexion_fk;
       knowledge_base          postgres    false    217    221    221    217    4823            �           2606    92499 5   preflexion_stage ffamily_name_fgroup_no_preflexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.preflexion_stage
    ADD CONSTRAINT ffamily_name_fgroup_no_preflexion_fk FOREIGN KEY (ffamily_name, fgroup_no) REFERENCES knowledge_base.family_group(ffamily_name, fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 g   ALTER TABLE ONLY knowledge_base.preflexion_stage DROP CONSTRAINT ffamily_name_fgroup_no_preflexion_fk;
       knowledge_base          postgres    false    217    4823    222    222    217            �           2606    92504 $   family_group fgroup_no_fish_group_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.family_group
    ADD CONSTRAINT fgroup_no_fish_group_fk FOREIGN KEY (fgroup_no) REFERENCES knowledge_base.fish_group(fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE;
 V   ALTER TABLE ONLY knowledge_base.family_group DROP CONSTRAINT fgroup_no_fish_group_fk;
       knowledge_base          postgres    false    219    217    4827            �           2606    92509    preflexion_stage stage_name    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.preflexion_stage
    ADD CONSTRAINT stage_name FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 M   ALTER TABLE ONLY knowledge_base.preflexion_stage DROP CONSTRAINT stage_name;
       knowledge_base          postgres    false    4835    223    222            �           2606    92514 #   flexion_stage stage_name_flexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.flexion_stage
    ADD CONSTRAINT stage_name_flexion_fk FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE;
 U   ALTER TABLE ONLY knowledge_base.flexion_stage DROP CONSTRAINT stage_name_flexion_fk;
       knowledge_base          postgres    false    223    220    4835            �           2606    92519 +   postflexion_stage stage_name_postflexion_fk    FK CONSTRAINT     �   ALTER TABLE ONLY knowledge_base.postflexion_stage
    ADD CONSTRAINT stage_name_postflexion_fk FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE;
 ]   ALTER TABLE ONLY knowledge_base.postflexion_stage DROP CONSTRAINT stage_name_postflexion_fk;
       knowledge_base          postgres    false    223    4835    221                        2606    92534 0   family_scorecard family_scorecard_sample_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.family_scorecard
    ADD CONSTRAINT family_scorecard_sample_no_fkey FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 Z   ALTER TABLE ONLY public.family_scorecard DROP CONSTRAINT family_scorecard_sample_no_fkey;
       public          postgres    false    236    227    4851                       2606    92524    group_decision fgroup_no_group    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_decision
    ADD CONSTRAINT fgroup_no_group FOREIGN KEY (fgroup_no) REFERENCES knowledge_base.fish_group(fgroup_no) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 H   ALTER TABLE ONLY public.group_decision DROP CONSTRAINT fgroup_no_group;
       public          postgres    false    4827    235    219            �           2606    92529 (   genus_scorecard genus_genus_scorecard_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.genus_scorecard
    ADD CONSTRAINT genus_genus_scorecard_fk FOREIGN KEY (fgenus_name) REFERENCES knowledge_base.family_genus(fgenus_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 R   ALTER TABLE ONLY public.genus_scorecard DROP CONSTRAINT genus_genus_scorecard_fk;
       public          postgres    false    226    216    4821                       2606    92539    fish_ratio sample_no_fk3    FK CONSTRAINT     �   ALTER TABLE ONLY public.fish_ratio
    ADD CONSTRAINT sample_no_fk3 FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 B   ALTER TABLE ONLY public.fish_ratio DROP CONSTRAINT sample_no_fk3;
       public          postgres    false    236    4851    234            �           2606    92544 #   classification_result sample_no_fk4    FK CONSTRAINT     �   ALTER TABLE ONLY public.classification_result
    ADD CONSTRAINT sample_no_fk4 FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 M   ALTER TABLE ONLY public.classification_result DROP CONSTRAINT sample_no_fk4;
       public          postgres    false    236    4851    225            �           2606    92549    genus_scorecard sample_no_fk6    FK CONSTRAINT     �   ALTER TABLE ONLY public.genus_scorecard
    ADD CONSTRAINT sample_no_fk6 FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 G   ALTER TABLE ONLY public.genus_scorecard DROP CONSTRAINT sample_no_fk6;
       public          postgres    false    236    4851    226                       2606    92554    group_decision sample_no_group    FK CONSTRAINT     �   ALTER TABLE ONLY public.group_decision
    ADD CONSTRAINT sample_no_group FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 H   ALTER TABLE ONLY public.group_decision DROP CONSTRAINT sample_no_group;
       public          postgres    false    236    4851    235                       2606    92559 5   shape_characteristic_result sample_no_shape_charac_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.shape_characteristic_result
    ADD CONSTRAINT sample_no_shape_charac_fk FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 _   ALTER TABLE ONLY public.shape_characteristic_result DROP CONSTRAINT sample_no_shape_charac_fk;
       public          postgres    false    229    236    4851                       2606    92564 )   sample_master stage_name_sample_master_fk    FK CONSTRAINT     �   ALTER TABLE ONLY public.sample_master
    ADD CONSTRAINT stage_name_sample_master_fk FOREIGN KEY (stage_name) REFERENCES knowledge_base.stages(stage_name) ON UPDATE CASCADE ON DELETE CASCADE NOT VALID;
 S   ALTER TABLE ONLY public.sample_master DROP CONSTRAINT stage_name_sample_master_fk;
       public          postgres    false    223    4835    236                       2606    92569 &   summary_ranking summary_sample_no_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.summary_ranking
    ADD CONSTRAINT summary_sample_no_fkey FOREIGN KEY (sample_no) REFERENCES public.sample_master(sample_no) ON UPDATE CASCADE ON DELETE CASCADE;
 P   ALTER TABLE ONLY public.summary_ranking DROP CONSTRAINT summary_sample_no_fkey;
       public          postgres    false    4851    236    230            �      x��}]��F���̯��T�N����x��9�S�ɞ��VmQ#qC�:��׿��ߤ��H$'�Gh4�@���i��~�_N7�~�wc���D�"J���r%�Y.b��ϯ7�X-�%���"^���(gp��VwƧ���58^.�����?��m�V|����E����z�2T��4�r8}zÙ����~;T������G�HQN�H��1���8Yę` �<����O@H-��*�c��7�I�W�/�#*�P�!/q���Q	����f_����"�x���&�E�"&d�����Ip�n榅�\����v�j���^���Ƌi'9�<ɐI�Ϥ ������ܑB��)�s�����_U�ٟ�<ں�f�8�����K.v�!ƹ�����%JN�X��υTU��и�s90�_O���p�S�
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
M�;B�����X��9(�%E�����Qv\!8�3�p�lʊ�%aleA$:�sB�D�O&�]#�ʥ�f'�3*��_����ʠz      �   �
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
<Am�.�	���&Jn����ͩ�O��i�E/�|���޾i��_pӢL}�A�&55گLE��6J��Z�)6P����g�����������z7�      �   Y  x��X�r�6}6��o��٪�X�/���MvS�JAd��DsA�^���4.�lj&y��nܺO�>Ж��S�ǋ��GR�V�頜kv�"����t���%��z�h����������ۉ��4^��`���-�����O�\�����<h����N�d�Y�﹙�ꕲM�W��q�M&�c9K�l{�:��n�G��Z���W�5�	Ύ۳[��9*r�K�^zY>=��^|ê�tt���+-��r�*�`A�-SG.M�4�8�Dq��#���'����~X�(��)t��K2i�G��P�۞m��Ƚx��O�d�yf;j������[��jȆ@��MNT>R�C�S_l�?M�SW�������S�'D��V�)�}�������-���'@@`oD��8j{U��)eըV�喛 �͌��4��,D����؏�S=�Ul�1* E����ۇm2��6���8C��cNwN��V��؆U�% �B��'w�5�u�;���mWqI����~�!�*d����?kD�}�����U5�Or�?=����-�)W��
ڒ����vk�	-7ʌ$�t��L��M�6X$O�Mܰ����	4�l泹Ƴ�V�&�r{��%.ޑ6܀���7T|�sZw��%���N��]�ӱVfح���]���.�N	&�����?���5~�;���@c���K���j藫Ζ[l5&�m=��]�M���vy�8������d�8� �kA{����!��m��p.�,�U���,��8�^������O�2_����:�p}?E0�&��� ]�h���}�ŵ!��܆(����躛�T���O�4~>�uʛ�x�_���A�Ð�8-w?���a���(��N���+U�����Pയ-���[��\J^�|��������r�N�����z������<ꡋ���mnpRo�$��Ғ��'�y,n������c����r��F�	A�k	�j!��b82���,6���e�ֲg��b\��,-6+�%P�^��٣�w�����h2z�ӭC͉q�x_�����z�\]��E*�AȜ�\�p�8��_����w<���bY�v�3�ɦ pJv ���y��8&��{C�J~.aB��eyOd�Vg�T�;\�R���0���Cƺ�@c�/j�vR���~Z"�=��9+B�Zn;��:����ۃ	3fb��범^�|�g�(������I>�IskU�����=�H�����+�8/��_|����e-y��q���������/��$\�4�S����\P������*�������^{�[d�?.�z!�w���Y(uMN-�A��p;�4����>���[��>/�v���$hr�q� �oV��b�h=�D�%������
�] %GO���~�Nmޛ@M�D;��R��P�zi���i><�h9��pF��l���S�����qӡSY�d��I�9q�_J��W0�^�e�qB���b�j���m���3蓗�W;y�́Z�L
���V~����Ŏ
P"\���
A"�'���_N^š=�:͖�����ApY^�&�%oH}뵈�OZ3ǐ� 1ͫ0��� ���ypP5��n%�kra�Q�Ø5��5	����-�+(�72T�
�x�.�,�w ����jR���;�[����H��z?����	G�pݹ���1�t��9��Х(��5٤Y�e�=����Y��b���^�V(�J�I�B��ӻ�Tu2lxs�u1:����E�U���-7���o#�5��*���1��`l�G�����=g�zQ�YL-WC�uz
ooUQ�_EҎ��E �t�T���5a�*ݦ�'u:����j���
*SJ�GyF��U�A��_{�� ��`�WR@3�@��:��廄FU�j��Q���"�o�vs�[<V������&�Ad�*u,�LQ��~�!	�z5���0�19���ȏ��Կ��>s1�!_Z/$�(zq,���S����p:| �����O�Ԓ�)Y.]���G��~M�����k�2��'��������)��BQ� ���\'~�����"���l�����6�O�j�I�~�{Q��DE�      �   s  x����N�@���S�Q$mi-z1A"x+`c�%�%��ww�B��l��&��L�z5߫z���8�T�S�ܯ�I�bL$�s�dmF���ݨ�W���Rm�*FW����%7�#l�TB'�O.�1�g�Z+�b��v��v��S�O�`\d0�\>����I��u2YË�������Q&H�I��J�¸}��=1o?8Su$p�~��g��Kh,����NY�3����t>$YD��@��-�Xf٦�U)�G�������r�t���?T*���_V�n�^����^���v�"vAZ�2y9B��R��)�b�9U��jo+�IOl�np䶜�v �b����G���#�`.I����9����T��8      �      x��][��~��yL!Ѕ��1mnE7��n
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
�z���	m�h�����t��H�]�U��A���->�/�G����	�@�^��yv:��ۚ�U�>�8��W���Q�qIQ�B�cMz^LJ.3�&CX��o��˯      �      x��][���~��yt7����iZ�q�:�&F���J,(Q�t��ߗ;3��(��n�:ycz?���\������9�w�c�Դ_��W��������t��_�o��u�M4�q4=�='�����\���I���I�鹘~���÷���8�p�͙��N�N�f�
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
�kPR9%���p-�&�V����q�v�z) ��/5I₃�z5)���l;̓G���v,�x�#��9,���p����M�Ѷ�F�� ���0����{�QT���>���y��c��[-�T�����j��%���Q�2��u<_����s�]^f7s�S,'�5�z&�@�S&�+'����j3cx ���o�T\�      �      x��]ێ�6}���y� ��%?�Lf'�̥�=,�4�[kk![�l�߯�"�C��Lӝ�Ql7K$�r�T���������n^�ի�����揶߾�5zG7ћ4y�Q>=�������o��W��*�_��2_]�[�;�{9~ɆϦ�f%_�1�9�e�|N�x9=G��q%��xz�b�36�S+e�s4.L!�����$��������D}�y�w;9�b>t��U��FL���cK���0˔����|ū��~ݶۺy}ߌc�u�M
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
��U�ᶋ��j�K瀞7����/������o�C���,�����~��%�.=<1��RPb��Lhb���� c2��\��g�7m�r�aQϹ�`t�	Ņ�#u�Ԝ<W��^��C�6Ϲ��ltvD�P���7WWW����Z      �   !   x�(J�M�I�����r����%p�=... ��      �   �  x����n�6�����:.�� �"��{�����(E��D}�����,�b��~�ə!g���$I�8H���F�FԌۮaJwc� "{ݲW�e?�~�}�!S�e�x'������z^&[�|��5�[���AT�ɕ������́If�P"��A�����"�s�Zw^)�Di'�?͆Z�4Z/ѿ��%2�gT5k�!!	Vk��f���Ǳ�|4�lX����������ut\P��o #U�!�b.`�c��t��^��c;1��_z�����Cf~��x+p�0)]k5��7f:ov�a�&�s@E �7I�����9s�6qAD�]L-t+A*+1��ZY����M���z���F(�o�4�@�TL_ǚ���]|D�]Å�6�vNJi��
�(�����s:)A}e�i�һ3�(F�` ��Q�o�YN�k��9A�dI��98��q�$�q�a��v��Y����)cʫ{	��r}1�-]���7,����m_�^"�FD�Ձ��o.����G.>�����LN.M?�c����%?�|�{?�WU⒡��o���Q��k�,?��005���Pp���͍���~�o� GλiVxھ�쑅�[�	��M-�DL䅭�X]�B�PL�T%wYQ��p;K����&���d��$�A�З9S1\�ee��	��&�Y0��0H�57�_\�|����e9�[͛S������x5* ����nW)<�<�2ְ/sR�B��M��RyѢ"vlTۓV�)]�F)m]�-j|�.yyπ3Ǝ+>���~����º�.�^��&�KD��]���I�E�*J�Ro�J��VI4���~�Y����	��"'�EE�V��HV��VH��rݪ��jIuUD,J�z�,�%��R�f��'}iu(^��N�y��e��/��5���8�v��m�')����*�G��0�pc��n���o�V˫��	�y2���U����>���b�@ɫ���%�N^ڪ�}|����O���'n8+����j�*��=<�v=���������ڵ�r�瘩�0��a�5�.�N>�S-�m��HC�#d�����*��^�F�F�y?g�F��ОKv�5��L�;�EvA�s/���	�>��î7 <�fVl�,�,\H����rPDB;,&xV��4�i��w�%$�{��S (�	j��c���!�rR�M�������(��'��Fs%�⼒��o�6�G,0iDG_��?�CQ,�#q��Q������8N�n� �u�w'�:c��������=sJɯ�#W#��>��a�t���y���Gu2��h깝u�f����g��/T�T��|�>�L՚斨��F�&�9�9�wF%���g�4�����i���Y�Α���=�����=<<�Լ�3      �   ?  x�͚ێ�6���O�h,Y���M�=�&E���Y�E
���o��kQ��d�,�^��F�?�!�t���nv�!6�{\a{��'�QԵP[��;^�B�M��%++��GV7���?i�'��A�%�l��j~��U�&p�[��8j~�����V��@'�����괏>G���6ڡu�Ifp�wjk�NU��L������f����i�����E���8�CK�N5�Zr��F��.:���Jo�j,Y$z��7��L��7|にmS Gjw��ޕ#s�ˋ+���ӛ8\������o��z�o�l
oY�p)�� _`��K�ċ�?k��>Z D'��Z�+��)5��aW�.ݐ?f���w#��Y91 $������j�%L �î�甊H�4G�d�K�DIb�#�G�ؚ���B�QbD�IiQ�E�3�X蒭�f0F��5�@fm��ѵ̰U��ѳ�O�#Yz�b��ҹ�6�,��Ax.��0,�N�xS�z;Ev�≗�*�=�����F�N%��a³B�w]��."�Ћ����ĦW���ʖ+����We"�5�|�6���Oخ}'����BE�)G�ߘp�H�r�3=�'=��E/8���Pt��62�n��m�b���I��Eh�/��$��2z��p���y�+-GU�x����҂��2��h�wl�쥮஽��|L�w���*k�EZ��A�j
ū��A6;�E�?����,#���$�B���%��=@��x%*2� ��=�e�zt�������h�,�k��E�f�#D��:1]A����U�Zcw�."ٸ�m����i��=���i��G��~��5v�W��.j�����7m��O�,h���]�;�@����8�q{�j�Fh��Ld//�6"����l�*��脉�Dp���-L;z�,��k��ꊴ��G�-������L4iEKv�1�&�(}E������(�#FQi�)g{��|�}t���Q�OU�Dy�y�Wsа���i*�I/�3b�ʥز�F�c��e��(���4�徬�}�z��]7�ʞb��nXe/����MV�[9�����h'�{3lTs��cS�i�s�^��跂�K�*G�+��5>i6� �k��7�f!h�*��8�,B��1l����4H /@�#�yPf���^[���xt��xɠcXqq��ʽ^	^��EMu6�߲�7w�$��ёX�{�t��u �=���Xꃓy�z1�)%#���u�T�Gb�<�ёXo6A�#���NQxx$6t}$6O�����͓l
op$��� �Ͽ]]]���X      �   n   x�=��� �RL�4�
쿎�d�g�N+z�1�F�<̍ie=�f�)'��@��J�}�*+�''Zz�}�:S�li��B�f'ĳ.K0��]��TZO�p��.y�#�      �      x�՝�r�6��;W���I����v�9��rrR[[�Q			������4HQ@iƚ�9��fIg�x� ^|u7��d~�]���L�dlC��m)��nI^�����=�x`y����W��4�d�����I��^>����_��RYе$��Z��8�~��τn�����.�?��i�Hˁ�9,�Q��M��H(y!҆�,��h��2�@�߫D�����X������C`��Y^(/�z!O`��O t���j���6���mwl��ǦAH��q!$I�l�#lwT���"g��U9���#X+"7��$Ao���;�u����	���o%)��B���d�Y�<�ډHT5mx������~αA<dI���0mW��J��gu��_x��������b��)�@��,sl����U��[$���BV<�i��Ͱ	F��AxW
�o��鴯D��M�|�U��F�B����ր��ea��H)�6G�p�K�#s��Eh&"V}Y��vx��O���g������ߠ��B}U�*�Z�b�b���5+���P8B`!����7\�S��k��j&+78�=3K�-�$����C�����)Qp\a�-�*��l����I��
��Hm>2�V�I�%۪�B�ӉY>�IΧO=�hxD�j��h�63�7��� ���eWr�67����%��H?���:�`P�+�$�Ƕ+���(H��Wzh�^?���sF���&�����Z���+D�]�	bWÀF�M,�UA�0pߛ��]�ԯ����{g�?��}Y����\����<c[쌲�lɚ���Y�5�9r;��%߰L��j�����C�ච�}��K��%��]\����Y�=�D��,A�{d�q����,���"(���3�^��F���wKW*���S�6��CK薌�N�	-�[�Q����=�!jAs����ܭ��d1	�8���=e;�������ދ7��Qtd}'�D���95pO	��告uU�XA�8�~�)�Y|���u�-�7�^1Iӵ@�����DQ8�aH;�>N�^f��)�A���� �1V��[�\��T��p�@�]���"�c�b4/�
��!� ��D��Y"����1Nq[�br�%W3h�.����-Ćʔ�V��wYDR�z=�\I��r[��1�Bcq���$� ?�r���b۾!����ۧ�*5h��+��<C����h�q�wI�g��#rUw��ruD$Cn��+��F�#u����ge��0�����t@ȃ@�
�ˎ���1qQ��I�B������{�Q�-_	J�QNK���ݲ�<��~R�)�)/������t��7��/�zh�HQ\9�ɤ��*�{����shnHWI��	M|�|���,/G�v;��g�&0ll8,w4eۤ����K�R=]���h2u o�_նU$[��G*���k.th`�֭9oܚ���d����2�q!�w��]��Z��iS~�P(����a=h\vw
��p�����nڸ�J�&��q]��J�����#��c�a	\��o��i���趤j]�qy=�ǰ�h-1l�v�W-�t������B�+e�A������P�g��"ٚ^¸��?�vX"�kW�_EF��%����xh���V1Q�Nd�=\+�#|�UR���#AC��F��v6�Qjo��B5)�a�����Ԭ1�o�|,��'�>h[���.NR]3)Y����Xї��ZİW�'�0ոr�}���i���F?�=R�*}Ч���8�Z$<L��*��o�voi�7
NK��+8������TK�Bd�#
N���q�������uE�����{�D��-F��i����3?�����Q�7��2�H@����e^���Έ�xZ�T�2a�F#��2�T�ˮ�Ъ��?��z#�鍧�~�m�hL��~U^���V��?����S�xG����#дO��;��[�+�j��	�vOX�[oC6ڬO�����	����d�B��%��'�6�+�u֧����#~��?�Td��*�#[^�:E�>�?P=P��K��O�XK
�J1�E���׎rw��R�}z�KȖ�B�Y%�>�?p�F���M�5��Q��{�E;$�u�t��5��5�����B@�[���~$3LM��*�3�2�&�����'^�v��L��~��m�=Y�lu��.����&s�ХGv�(8wlh��|�4n˺)n!��9�wπ����Ji!2�9G���oR+ԡ�v�E){�ȇc��/�-B\0�p f@�d��"� H�HX��!����@W�ވ1w0n�P�Pv�+�AY8($!�Ƙ9<K�<R59�Q";������8(���-:�隨��8��c7]��>0@\�l�\Q)�y�/�� g��o@
�"�P���ǈ��2�: �#͎!�H�T�GY�ZF�Qa��D�(b��oǊ��ǰ�I&����4�1��lkV�v��rȏ&���D2Bk��c<��_�����U�G�v-���ĩ�>?�訚?�>��yT�_DN8�tFGe\�t�9���� 	䓪�%�3�[QdOa_��,�~�;]���_����Q_�v���d21˿��m��'���x&��I�/�7�u:W˾��,��A��<����	Y��( 3`U~����r�ΧJ�d�i�
ix��S���F�zܝ���Z�� �f��4݃�A=Bor���qP�4�s�8t}y�i��#F��<��"�$K1MO3u�Ϭ��kJ�Dd�$n����\W����D��	�<}
}��hh"�O��]�G���/�է�#�F��d�tH��H}*=F(䞧O��C �(}}<�qP�>q�r��H}�|"�q����!�C['��㡍C'��/�4
�'�_e��O�O�0ԧ�=��(,�U�YD�9-�m�"
�im�C�9��nh�0�E�	I�gzZ�{C�9��=!�������AyN�r��@�e�
5��0wB1��Ӳ�Z8(�ie�	)��8�P�imnC1�t��$��Cs2�$�?���"���m��M_,~�������!ϸv� �)vU���s�:8�����i
f��ܐ���![%tAX����(s�6���R�;&[��pX~��b�O�<0^�l�ʎ�>
M8qh�IقA2M�90Or�/,�+�0�یԍBWvk���U;,$Wz��tc5W|�i&�2���\�]ej��#K�+�����L�f�R���:�I�7$��p�`��&�4Q3u�b��7�t2�� l��=���ϼ�P��7V���J�!bh�����G��O#��2��p�5f����B��&X?�.�t�[�a����^x�?��-)�o�n��!Y�$��(2I9�ňL����0b;0t�[�j�U�p�U>� N��p��U��{��H�z�YdV�&���7b>�?	�a���W`>�'��̴�%�TƸ�ӷa�*���yw_)[�D���8÷qB"��f��s���(o���0n��\�	���%.e�&ʏj�e�,�0����~�4a�5����tqǭ��kƝ�
�`�U��1G� �|ol~%�ִ8�0�|TL�>2�'�V K�b�Y�#��i�4{�z�1�bX������-7E�"�, �`ǻ�O�騿.��Ć�.���H��*��^��s���A�&�#U��`8'OG�Oy�����@�-�L��U�Hf.�n ���Ó�Ɋ�m���#����(>j�y���%�o�~�TUO�
�SV�4�>��TpÏt�7q(>���sx:*�dh�P������N�&�0��j�t��� U�E3E�}JO�uA�gd��E� N<��R�ů4�X\��]{:��,~o2o@�JI����fhg�X�IpMh�&������j�q/�"�L�ۂ���y:D�CP�աJ�:���`ܫ�Rw�#����Џ�3���jޅ:��awX����t�R���C�,K8���N\�Xʩ]��j`��3��t1�8$�|��T-��$~/	�r���C���t����ߣC �  ��\�P�bIW�i��9!)�/�Z�}��[~Jx���K?w��������HvD��"Bg�������1o}���p�,�t� v��I��Q:��bI)k�/$��a�-!��2 ����$IŎ<3&pű}����M]}|z�R���L� �V���$ �[�U�%���V/>�/�d��[��H��̕���?E�3W+��1$Cj3W'W�W��'!(Fp��eGR�.���� �nb֯Me ��u��C�4�A����:�y�C�U�QNK\�E�� @/i�Z���Oǒ0z�k��^�P<E{��YI�8|�c��!S.�����!�F���Y7/S�{ȯ��,�֓�cx��%��5@JQ�jP$�~�&=3��ӑb�$�6���,$)v$��P����%˨l۝h*c����CŖ	l�f���.�o��9�sq�ex� X�����������2�X  u��Z$?JRn��H"�cƺ�ߎa��bC Lt�XB��Ԝ�>,A0��[�����N�~��ɥ�ƺ$?����'�:,�K��i��뭣#���.t1M2�9��yhA����#U/
	��Qh�,���܈r-ʄT�m&v��,�4��E�@ԡVJ}�!���b7�ȡ�H!����&���h�	SV"υٿ�
\�$�V����E��u��'a��z��}�����PA�'��F�>�*��(d4ۄ���*Ip�h�r�<��%^�m6�,&^�p���(�M�Lu�N����*�������ڶJ�j;2q��NM�0N��ϡ��㻫Q�����l>��:�Dۦ�X]��Z�e��M�	qz�O\��g���K�m�
�U�N��/�C�&��qI��*�,2w�̟��ұ
����3����z|�g�4��6="��7l��\5_t��PC�R�P�J���<v7��_��?���r_��w��3�FX��:��YZ$X�Y���;\{�EJ���Md��VR�"m�D�Z:8���gT�*!?�&��QÒ,u���d\��u���q]�1A5�oB| ;��	F�H`��Å���5&��z��N��Y13�B�q<Dc�&��r�6Z�[@�o��+��F�0��G�8��������L y�X	,��'�9�+m7��n��3یeKnٚ��}`I�S!��<�hL{!��ϑ*ƒ�%�u�	B �K�[��tv	a�nc�����(�2b��Э[l9Vs�Z�\H��z�ǒ�_ҵd��M-i�75���ZY|yws�Z�2�DՒ��B)��Y0 f&��2�t���Iq[��������K�d\a�,,H
�_)�I���y�'��������xV�QR���R���+�dS�<"[!�Ei�m�C���eWr���ȧ�ڥ�Z�	�gm��uB֨7 ���'_$cy�=�u;|�p ��p0��,���"��4:YD�o�`�!�����L���آ�i�C���	f��.� �	c�L�j(g#5cG��EQ�:�"ˡ#�7�W3h5ߋsL�v�G;許�~�(��Z�mZYd�qt���4�m�#�?m���W�����a�We����F��ޖ��c��=�
���N�FԽ�#���I{�b�����Gڤ�>��H�2w$X��T2��4ʄf�(�S��Қe�hm'2{b5w�V_sN���pw	�0������px	��8��p�N�3��-���c$d���.;M{�Z8\_���Q�}VUC�&|�:r�we,ߐ�vG~�/�R� ���$j��I9⻢k�[����Ӊ"GzW��P�8f�z?r�we�.V9b�䐲{*9��BI�hc+q�h�l��:q�H{y������i:�չTͭ�v���pmu��*#ƑoF���/��	Ըi_�p��mv8d� �qo-��/^��!˷]�֒@.��P�G���:�H��s].�6��:�v��Љ)�m�.���,̌�Y� '�t�YKp����֜@��� ��wg���L}�"WϨ���N�9i��x�pBb�b�pǳ�3D�yG�p�*�Z�J��c��Y?�k��W?T���������M�}��M�A�Jդ���L����@s��r�d�� 	m��6�܆x�U<Yg+6��_J�
��"ٶ��+Ɇah:�� p<o�-",� �SS��k�����j;���뤯I��i�p�`�!��&��h��	�F�J_V��h{#1?@��r"c�Q��`P,�}C��Bt1��R3�,P�|۾u����H�;6o#	&�H
d��S�S2�V��B��$��F2<K��+&��C��f�:(��ح6�E3sh^���Ȭ��A*�vX\W��ۜ5��  �[@�sG�Y�^�1�j�5��� �,�I��58��Mj��Vq=H�Q�S��I3��!�y�׃��)�-$��׏Ƭax��dX�%yE%�ZR���s��$3���	�Լ�ox���P���1��ǘ��U��!��A���$�� H����%���"��I:w� ����ļ�*��b��E�����$n&��Y�Ao̝�,����yE���.����ɒ�۹�V��o�y�w�3�DZ�@�zX��e�2��E=P;���(1�N\��!�۴�m)�\�{�����)�]���M*>�0���.;�2D����R�M��ۈ:��ez!�O�l煨uף��U-.����(����WB�B*ۊCe��*��y��������tW/1~��R�=n�i�|⠴o����$�C�j�p�w�(��������KMԪ��N'B�q�v#d~��T��}6}��a�r���|���k>������9���k�|�~+������W͜���a�"{���_�{[H��^�i�|S{c�N6�.?j�|ԏ����mz��E�W9�v�|�=j1q>/��Wy�W=��;��4"Y7�]������p':l��w.wZ�L3��1�����y�*cp�_Ɗw�����7?�Z|kFs��<#y�V�׮�����ψ�?��}�M�o�F,�����7�l�{kL��~F��hJ��7�7�ӌl�[ML��`�>�ffb���3��9�9�j�	7�o��c��"��r�%{���RV��t���7to�����pP���$r8V"���B��Y��g�L's����X��U"���޼��b�T��߄������3I:�o��O|�ߞRΧ�'
���q�BoKo����#wT���"?�taV��d�f�&	A�-P���g���5h�-�JR��Xº�`@,,�[KmD$��F��v�S?����X���-K3�xK������=�<gE���]��f�m�B��N�����\Cs��������9�q9B?�@_W��o����\����7e����UՉ6�#R��:1�(
��m�)!c�`�z�l�:+V^&����~�8�HT      �   K   x�31�4C8���L�9�8M��`, �eb�i�i��!i
�gh�n"�\3NSNCKLC!��f(NBbq��qqq �I[      �   �  x����J�@��'O�Ȳ��\�U+JK��қ�Yi5Md��y{g�bU��d7���d,w�T��Re�f<?[��=��s�iT�ń�r��`
w�
6s���P�A���!{��۾��%Nk���P?���<Ç?���r���JK�E(J��Ɛ�+)J�]�NOm:i�U(S_�h/~ۦ�>V]�`_����g6��F �,+,�aR�!-֒spL��S7/K,T
��a�� ix��ݯ@�� �����RIa�MM龙|��x��zn�(V�T?���t_&&�c�#
�2$�9�td���ܕL�	�]4��ҫ&�l�6���қʷm�C�X�k�Ry� �gk�����U��Α�zK�M�gW�gwÒ$y)��o      �   u   x�371�4°ԢJל���ĒTN����" C�#51��'�(=U��2���Đӈӄ�B8�ֈӘ�.�_�1�TCN����}V�p�rZB\�O�)����ssrЕ��qqq �9K�      �     x���r�����l6<r�Ѻj6kOT#e��ja� �����ӧI�H�v�v$KM_���F_w��h6��3c��2e�b	�Ƥ(*���p̿����а�cˋ�{VL���W�0�0˔�s�圚��(����M
��;�/N�5������~�w��a���I>�3Z�\
|��<%B�U� ����Ȓ�rC7/������� ���0f)͉ �o��;*Vej� ��yGs� �ys�XQʒ!�����xs*Zd�Z��_8���H��D1&�1�%[������Cۻ"Nۺq}@�9�:Q�|��s<Ռ�'�4���_dF��T�������_��)�r�*�O-�?8wې=M�q#���"�s_�"!#�hin�+�h~�~t�@��|d��J�,C�Nh�`��)��t\� 
u!����d���nd���G3Ap*�P��F��w��+��uOI��L1��BƊ�0e�Ȓ��Ő�p�1�EvCW������j��G��J��}�"<�
��c�2��l ����Ƭ��/`��	�'���rT���	a�ԱF]_�@EL����{)6Y���_�)A�uN�aX�V����)�r
��b;�{W��]�qt��P%�1�Qj�P�=���q�Q�n'ƽ� 'w���=M��N��C�������4�_H�\s�t=�:0+ �e3w;;xV��C}��+�؊�s���٭��������O� �i��Fe��Q@;D�v48�h8M��h�wZNو�ȸ�D�k���R�Ѧ�HW�f�#�]d����� ��uO�1p��`�=��x3����g��D�@���r�v���҂�g��=�2]�+\�{������"(N��Wi-J� +�:+|�vF�8{�q0��:/��8��@z�3A�r& k̩R��xaޱ\�k����������ݓV��
����F#|'L<J�0LFp�]�	��Ӑn黶�gD�<k����k�KE�:r�!O%���)s�1����ȝ�$�4�/��i���k��z^g�cX�Ծ>�SBK�P�!Ў�1�{���F95;�\U3coG�`��z"+���Y�`��V�̐ד��>i}�X_bm=s�K��m�iΰzY���dp-��nh���0^H��W�W�����g%���a��r*h�:nC�{�n�M�k�7%�q��ұ]�v���5R�;��s��?߁�y�=��iV��38'5�'ݤ��@$J#�	�	��9ԉ ����vW�����k���F>\4�O|����w�`�@�K�xp�A�Y�_D8���|1\3�4_�:A�e`x�
B�!�atM5���a�b=}a�.�;�<�Y S�����H���Cs'�S�.��e���ET�nt�@���UK9YA�7�לIQ���a��gDtn���*�y�ۜm��ɓV'l�j�v]��գ��"�s���,��I%zBEK��� �lXΛ�j<�|�Ok!&�Em�;��J�V!�yz)�Z4o� ���QY��t��4�fDں��p:M?g���Z�T��Y�{JY�m3o��$��#�6/�)֠� �H�k�3�#%y��G�yO���8�ǀ�1�\�a�{�K�oA��*�@�z`F}��&��� �T��a�9P�SSY~�>�#N�_��������e���%�`��6գͶ�
���.�0BJ��SC�&pu��<}�v�k1A=<�wdu�8
#���A}� ��n�Z̵�`fu3��TR%a%6���6X�?�c����i�Z`�Tbs�,i�H{A(ąT��؊
�Gc��h@$.�|s(3�l9F`Ly�ӦEǄˢn�a|e�ص�Y���zV�� ��.��\��� �V����[��+��ua�u��=�[�T� Y/��3�&�;T�-�^�Z'�@Cݼ.PQ�=��+�'=G��s��EQuNK�3!>�����eܧ,�[�S�*T�[=�E]�S�ʶ���c9P���ɗ��;}�ݳX0C���Q,N�*����r��ׇ֞J����o7��|ss�?8v�0     