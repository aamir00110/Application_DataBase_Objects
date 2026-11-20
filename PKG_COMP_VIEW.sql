create or replace PACKAGE PKG_COMP_VIEW AS

    -- Returns premium HTML card for ONE complaint, searched by COMPLAINT_NO.
    -- P_INCLUDE_CSS = 'Y' -> <style> block is included in the output
    --                 'N' -> only HTML (use if you put GET_CSS in page CSS)
    FUNCTION GET_COMPLAINT_BY_NO (
        P_COMPLAINT_NO IN VARCHAR2,
        P_INCLUDE_CSS  IN VARCHAR2 DEFAULT 'Y'
    ) RETURN CLOB;

    -- Only the CSS (without <style> tags)
    FUNCTION GET_CSS RETURN CLOB;

END PKG_COMP_VIEW;
/

create or replace PACKAGE BODY PKG_COMP_VIEW AS

    ---------------------------------------------------------------
    -- CSS
    ---------------------------------------------------------------
    FUNCTION GET_CSS RETURN CLOB IS
        L_CSS CLOB;
        PROCEDURE A (P_TXT IN VARCHAR2) IS
        BEGIN
            L_CSS := L_CSS || P_TXT || CHR(10);
        END A;
    BEGIN
        A(q'[
.cv-wrap{--navy:#0f172a;--navy2:#1e293b;--gold:#c9a24b;--ink:#0f172a;--mute:#64748b;--line:#e2e8f0;--bg:#f1f5f9;
  --ok:#059669;--warn:#d97706;--bad:#dc2626;--info:#2563eb;
  font-family:'Inter','Segoe UI',system-ui,-apple-system,Roboto,Arial,sans-serif;color:var(--ink);max-width:1100px;margin:0 auto;padding:8px;box-sizing:border-box}
.cv-wrap *{box-sizing:border-box}
.cv-card{background:#fff;border-radius:20px;overflow:hidden;box-shadow:0 20px 45px -15px rgba(15,23,42,.25),0 2px 6px rgba(15,23,42,.06);border:1px solid var(--line)}
.cv-hero{position:relative;padding:28px 32px 26px;color:#fff;background:linear-gradient(135deg,#0f172a 0%,#1e293b 55%,#334155 100%);overflow:hidden}
.cv-hero:before{content:"";position:absolute;right:-80px;top:-80px;width:260px;height:260px;border-radius:50%;background:radial-gradient(circle,rgba(201,162,75,.35),transparent 70%)}
.cv-hero:after{content:"";position:absolute;left:0;bottom:0;height:4px;width:100%;background:linear-gradient(90deg,var(--gold),#f4d58d,var(--gold))}
.cv-hero-row{position:relative;z-index:1;display:flex;justify-content:space-between;align-items:flex-start;gap:20px;flex-wrap:wrap}
.cv-eyebrow{display:block;font-size:11px;letter-spacing:.22em;text-transform:uppercase;color:var(--gold);font-weight:700;margin-bottom:6px}
.cv-no{margin:0;font-size:32px;line-height:1.1;font-weight:800;letter-spacing:.5px;color:#fff}
.cv-sub{display:block;margin-top:10px;font-size:13px;color:#cbd5e1}
.cv-sub strong{color:#fff}
.cv-badges{display:flex;gap:8px;flex-wrap:wrap;justify-content:flex-end}
.cv-badge{display:inline-flex;align-items:center;gap:6px;padding:6px 14px;border-radius:999px;font-size:11px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;background:rgba(255,255,255,.12);color:#fff;border:1px solid rgba(255,255,255,.25);backdrop-filter:blur(6px)}
.cv-badge:before{content:"";width:7px;height:7px;border-radius:50%;background:currentColor}
.cv-b-progress{background:#dbeafe;color:#1d4ed8;border-color:#bfdbfe}
.cv-b-closed{background:#dcfce7;color:#047857;border-color:#bbf7d0}
.cv-b-resolved{background:#ccfbf1;color:#0f766e;border-color:#99f6e4}
.cv-b-danger{background:#fee2e2;color:#b91c1c;border-color:#fecaca}
.cv-b-warn{background:#fef3c7;color:#b45309;border-color:#fde68a}
.cv-b-overdue{background:#dc2626;color:#fff;border-color:#dc2626;animation:cvPulse 1.6s infinite}
.cv-b-default{background:#e2e8f0;color:#334155;border-color:#cbd5e1}
.cv-b-p1{background:#fee2e2;color:#b91c1c;border-color:#fecaca}
.cv-b-p2{background:#ffedd5;color:#c2410c;border-color:#fed7aa}
.cv-b-p3{background:#fef9c3;color:#a16207;border-color:#fde68a}
.cv-b-p4{background:#e0f2fe;color:#0369a1;border-color:#bae6fd}
@keyframes cvPulse{0%{box-shadow:0 0 0 0 rgba(220,38,38,.55)}70%{box-shadow:0 0 0 10px rgba(220,38,38,0)}100%{box-shadow:0 0 0 0 rgba(220,38,38,0)}}
.cv-kpis{display:grid;grid-template-columns:repeat(auto-fit,minmax(190px,1fr));gap:16px;padding:22px 32px;background:var(--bg);border-bottom:1px solid var(--line)}
.cv-kpi{display:flex;gap:14px;align-items:center;background:#fff;border:1px solid var(--line);border-radius:16px;padding:16px 18px;box-shadow:0 4px 10px -6px rgba(15,23,42,.15);transition:transform .2s,box-shadow .2s}
.cv-kpi:hover{transform:translateY(-3px);box-shadow:0 12px 22px -10px rgba(15,23,42,.25)}
.cv-kpi-ico{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:20px;background:#eff6ff;flex:none}
.cv-kpi-resp .cv-kpi-ico{background:#eff6ff}.cv-kpi-reso .cv-kpi-ico{background:#ecfdf5}.cv-kpi-down .cv-kpi-ico{background:#fff7ed}.cv-kpi-cost .cv-kpi-ico{background:#faf5ff}
.cv-kpi-alert{border-color:#fecaca;background:linear-gradient(180deg,#fff,#fef2f2)}
.cv-kpi-alert .cv-kpi-ico{background:#fee2e2}
.cv-kpi-val{display:block;font-size:20px;font-weight:800;color:var(--ink);line-height:1.15}
.cv-kpi-lbl{display:block;margin-top:3px;font-size:11px;letter-spacing:.1em;text-transform:uppercase;color:var(--mute);font-weight:600}
.cv-track{display:flex;padding:28px 32px 10px;gap:0}
.cv-step{flex:1;position:relative;text-align:center;padding-top:34px}
.cv-step:before{content:"";position:absolute;top:11px;left:-50%;width:100%;height:3px;background:var(--line);z-index:0}
.cv-step:first-child:before{display:none}
.cv-step.is-done:before{background:linear-gradient(90deg,var(--ok),var(--ok))}
.cv-dot{position:absolute;top:0;left:50%;transform:translateX(-50%);width:26px;height:26px;border-radius:50%;background:#fff;border:3px solid var(--line);z-index:1;display:flex;align-items:center;justify-content:center;font-size:12px;color:#fff}
.cv-step.is-done .cv-dot{background:var(--ok);border-color:var(--ok)}
.cv-step.is-done .cv-dot:after{content:"\2713"}
.cv-step.is-cancelled .cv-dot{background:var(--bad);border-color:var(--bad)}
.cv-step.is-cancelled .cv-dot:after{content:"\2715"}
.cv-step.is-cancelled:before{background:var(--bad)}
.cv-step-lbl{display:block;font-size:13px;font-weight:700;color:var(--ink)}
.cv-step-dt{display:block;margin-top:2px;font-size:11.5px;color:var(--mute)}
.cv-step.is-pending .cv-step-lbl{color:#94a3b8}
.cv-body{padding:18px 32px 8px;display:grid;gap:22px}
.cv-section{border:1px solid var(--line);border-radius:16px;padding:20px 22px;background:#fff}
.cv-sec-title{margin:0 0 16px;font-size:12px;font-weight:800;letter-spacing:.16em;text-transform:uppercase;color:var(--navy2);display:flex;align-items:center;gap:10px}
.cv-sec-title:before{content:"";width:4px;height:16px;border-radius:2px;background:var(--gold)}
.cv-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px}
.cv-field{background:#f8fafc;border:1px solid #eef2f7;border-radius:12px;padding:12px 14px}
.cv-field.span-2{grid-column:span 2}
.cv-lbl{display:block;font-size:10.5px;letter-spacing:.12em;text-transform:uppercase;color:var(--mute);font-weight:700;margin-bottom:4px}
.cv-val{display:block;font-size:14.5px;font-weight:600;color:var(--ink);word-break:break-word}
.cv-note{margin-top:14px;background:#fffbeb;border:1px solid #fde68a;border-left:4px solid var(--gold);border-radius:12px;padding:14px 16px}
.cv-note p{margin:6px 0 0;font-size:14px;line-height:1.6;color:#334155}
.cv-note.note-danger{background:#fef2f2;border-color:#fecaca;border-left-color:var(--bad)}
.cv-note.note-plain{background:#f8fafc;border-color:var(--line);border-left-color:var(--navy2)}
.cv-table-wrap{overflow-x:auto;border:1px solid var(--line);border-radius:12px}
.cv-table{width:100%;border-collapse:collapse;font-size:13.5px}
.cv-table thead th{background:var(--navy);color:#fff;text-align:left;padding:12px 14px;font-size:11px;letter-spacing:.1em;text-transform:uppercase;font-weight:700;white-space:nowrap}
.cv-table td{padding:11px 14px;border-top:1px solid var(--line)}
.cv-table tbody tr:nth-child(even){background:#f8fafc}
.cv-table tbody tr:hover{background:#eff6ff}
.cv-table .num{text-align:right;font-variant-numeric:tabular-nums}
.cv-table .act{text-align:center;width:110px}
.cv-table tfoot td{background:#fef9e7;border-top:2px solid var(--gold);font-size:14px}
.cv-del-btn{cursor:pointer;border:1px solid #fecaca;background:#fff1f2;color:#be123c;border-radius:8px;padding:6px 12px;font-size:12px;font-weight:700;transition:all .15s}
.cv-del-btn:hover{background:#be123c;color:#fff;border-color:#be123c}
.cv-foot{display:flex;flex-wrap:wrap;gap:8px 26px;padding:16px 32px;margin-top:10px;background:var(--bg);border-top:1px solid var(--line);font-size:12px;color:var(--mute)}
.cv-foot strong{color:var(--ink)}
.cv-empty{padding:60px 20px;text-align:center;color:var(--mute);font-size:15px}
.cv-empty b{display:block;font-size:40px;margin-bottom:8px}
@media(max-width:700px){
 .cv-hero,.cv-kpis,.cv-body,.cv-foot{padding-left:16px;padding-right:16px}
 .cv-track{padding:22px 10px 6px}.cv-step-lbl{font-size:11px}.cv-step-dt{font-size:10px}
 .cv-no{font-size:24px}.cv-field.span-2{grid-column:span 1}.cv-badges{justify-content:flex-start}}
@media print{.cv-del-btn,.cv-table .act{display:none!important}.cv-card{box-shadow:none}.cv-hero{-webkit-print-color-adjust:exact;print-color-adjust:exact}}
]');
        RETURN L_CSS;
    END GET_CSS;

    ---------------------------------------------------------------
    -- MAIN FUNCTION
    ---------------------------------------------------------------
    FUNCTION GET_COMPLAINT_BY_NO (
        P_COMPLAINT_NO IN VARCHAR2,
        P_INCLUDE_CSS  IN VARCHAR2 DEFAULT 'Y'
    ) RETURN CLOB
    IS
        L_HTML        CLOB;
        L_COUNT       PLS_INTEGER := 0;
        L_STATUS      VARCHAR2(100);
        L_STATUS_CSS  VARCHAR2(30);
        L_PRIO_CSS    VARCHAR2(30);
        L_OVERDUE     BOOLEAN;
        L_NOW         DATE := SYSDATE;
        L_RESPONSE    VARCHAR2(50);
        L_RESOLUTION  VARCHAR2(50);
        L_DOWNTIME    VARCHAR2(50);
        L_PART_NO     PLS_INTEGER;
        L_IS_AMIR     BOOLEAN := UPPER(NVL(V('APP_USER'), 'X')) = 'AMIR';
        L_CAN_DEL     BOOLEAN;

        FUNCTION ESC (P_VALUE IN VARCHAR2) RETURN VARCHAR2 IS
        BEGIN
            RETURN APEX_ESCAPE.HTML(NVL(P_VALUE, '-'));
        END ESC;

        FUNCTION ESC_BR (P_VALUE IN VARCHAR2) RETURN VARCHAR2 IS
        BEGIN
            RETURN REPLACE(
                       REPLACE(APEX_ESCAPE.HTML(NVL(P_VALUE, '-')), CHR(13), ''),
                       CHR(10), '<br>');
        END ESC_BR;

        FUNCTION FMT_DT (P_VALUE IN DATE) RETURN VARCHAR2 IS
        BEGIN
            IF P_VALUE IS NULL THEN RETURN '-'; END IF;
            RETURN TO_CHAR(P_VALUE, 'DD-MON-YYYY HH24:MI');
        END FMT_DT;

        FUNCTION FMT_NUM (P_VALUE IN NUMBER) RETURN VARCHAR2 IS
        BEGIN
            IF P_VALUE IS NULL THEN RETURN '-'; END IF;
            RETURN TO_CHAR(P_VALUE, 'FM999G999G990D00');
        END FMT_NUM;

        FUNCTION FMT_MIN (P_VALUE IN NUMBER) RETURN VARCHAR2 IS
            L_M NUMBER;
        BEGIN
            IF P_VALUE IS NULL THEN RETURN '-'; END IF;
            L_M := ROUND(P_VALUE);
            IF L_M >= 1440 THEN
                RETURN TO_CHAR(TRUNC(L_M / 1440)) || ' d ' ||
                       TO_CHAR(TRUNC(MOD(L_M, 1440) / 60)) || ' h';
            ELSIF L_M >= 60 THEN
                RETURN TO_CHAR(TRUNC(L_M / 60)) || ' h ' || TO_CHAR(MOD(L_M, 60)) || ' min';
            END IF;
            RETURN TO_CHAR(L_M) || ' min';
        END FMT_MIN;

        FUNCTION BADGE (P_TEXT IN VARCHAR2, P_CLASS IN VARCHAR2) RETURN VARCHAR2 IS
        BEGIN
            RETURN '<span class="cv-badge ' || P_CLASS || '">' || ESC(P_TEXT) || '</span>';
        END BADGE;

        FUNCTION FIELD (P_LABEL IN VARCHAR2, P_VALUE IN VARCHAR2, P_CLASS IN VARCHAR2 DEFAULT NULL)
            RETURN VARCHAR2 IS
        BEGIN
            RETURN '<div class="cv-field ' || P_CLASS || '">' ||
                   '<span class="cv-lbl">' || ESC(P_LABEL) || '</span>' ||
                   '<span class="cv-val">' || ESC(P_VALUE) || '</span></div>';
        END FIELD;

        FUNCTION KPI (P_ICON IN VARCHAR2, P_LABEL IN VARCHAR2, P_VALUE IN VARCHAR2,
                      P_CLASS IN VARCHAR2 DEFAULT NULL) RETURN VARCHAR2 IS
        BEGIN
            RETURN '<div class="cv-kpi ' || P_CLASS || '">' ||
                   '<span class="cv-kpi-ico">' || P_ICON || '</span>' ||
                   '<div><span class="cv-kpi-val">' || ESC(P_VALUE) || '</span>' ||
                   '<span class="cv-kpi-lbl">' || ESC(P_LABEL) || '</span></div></div>';
        END KPI;

        FUNCTION STEP (P_LABEL IN VARCHAR2, P_DATE IN DATE, P_CLASS IN VARCHAR2 DEFAULT NULL)
            RETURN VARCHAR2 IS
        BEGIN
            RETURN '<div class="cv-step ' ||
                   CASE WHEN P_DATE IS NOT NULL THEN 'is-done' ELSE 'is-pending' END ||
                   ' ' || P_CLASS || '">' ||
                   '<span class="cv-dot"></span>' ||
                   '<span class="cv-step-lbl">' || ESC(P_LABEL) || '</span>' ||
                   '<span class="cv-step-dt">' || ESC(FMT_DT(P_DATE)) || '</span></div>';
        END STEP;

        PROCEDURE PUT (P_TEXT IN VARCHAR2) IS
        BEGIN
            L_HTML := L_HTML || P_TEXT;
        END PUT;

    BEGIN
        IF UPPER(NVL(P_INCLUDE_CSS, 'Y')) = 'Y' THEN
            L_HTML := '<style>' || GET_CSS || '</style>';
        END IF;
        L_HTML := L_HTML || '<div class="cv-wrap">';

        IF TRIM(P_COMPLAINT_NO) IS NULL THEN
            PUT('<div class="cv-card"><div class="cv-empty"><b>&#128269;</b>' ||
                'Please enter a complaint number.</div></div></div>');
            RETURN L_HTML;
        END IF;

        FOR C IN (
            SELECT
                H.COMPLAINT_ID,
                H.COMPLAINT_NO,
                H.COMPLAINT_DATE,
                H.REPORTED_BY,
                (SELECT EH.HALL_NAME FROM EM_HALLS EH
                  WHERE EH.HALL_ID = H.DEPARTMENT_ID) AS DEPARTMENT_NAME,
                (SELECT L.LINE_NAME FROM EM_LINES L
                  WHERE L.LINE_ID = H.LINE_ID) AS LINE_NAME,
                EM.MACHINE_NAME || ' MODEL# ' || EM.MODEL_NO || ' SR# ' || EM.SERIAL_NO || ' ' || EL.LINE_NAME AS MACHINE_NAME,
                (SELECT EMF.FAULT_NAME FROM EM_MACHINE_FAULTS EMF
                  WHERE EMF.MACHINE_FAULT_ID = H.FAULT_ID) AS FAULT_NAME,
                H.PRIORITY_ID AS PRIORITY_NO,
                CASE
                    WHEN H.PRIORITY_ID = 1 THEN 'Critical - Line Stopped'
                    WHEN H.PRIORITY_ID = 2 THEN 'High'
                    WHEN H.PRIORITY_ID = 3 THEN 'Medium'
                    ELSE 'Low'
                END AS PRIORITY_NAME,
                H.FAULT_DESCRIPTION,
                H.PRODUCTION_IMPACT,
                H.MACHINE_STOPPED,
                H.STATUS_CODE,
                H.REPORTED_DATE_TIME,
                H.ACKNOWLEDGED_DATE_TIME,
                H.RESOLVED_DATE_TIME,
                H.CLOSED_DATE_TIME,
                H.DOWNTIME_MINUTES,
                H.REOPEN_COUNT,
                H.REJECTION_REASON,
                H.REJECTION_DATE_TIME,
                H.EXCEPTIONAL_CLOSURE,
                (SELECT SUM(NVL(MP.CHANGE_PARTS_QTY, 0) * NVL(MP.CHANGE_PARTS_PRICE, 0))
                   FROM MS_CHANGE_PART MP
                  WHERE MP.COMPLAINT_ID = H.COMPLAINT_ID) AS TOTAL_COSTING,
                (SELECT COUNT(*) FROM MS_CHANGE_PART MP
                  WHERE MP.COMPLAINT_ID = H.COMPLAINT_ID) AS PARTS_COUNT,
                H.REMARKS,
                H.CREATED_BY,
                H.CREATED_DATE,
                H.UPDATED_BY,
                H.UPDATED_DATE
              FROM MS_COMPLAINT_H H
              LEFT JOIN EM_MACHINES EM ON EM.MACHINE_ID = H.MACHINE_ID
              LEFT JOIN EM_LINES    EL ON EL.LINE_ID    = EM.LINE_ID
             WHERE UPPER(TRIM(H.COMPLAINT_NO)) = UPPER(TRIM(P_COMPLAINT_NO))
             ORDER BY H.COMPLAINT_ID DESC
        )
        LOOP
            L_COUNT   := L_COUNT + 1;
            L_STATUS  := UPPER(NVL(C.STATUS_CODE, 'UNKNOWN'));
            L_CAN_DEL := L_IS_AMIR AND L_STATUS <> 'CLOSED';

            L_STATUS_CSS :=
                CASE
                    WHEN L_STATUS IN ('IN_PROGRESS', 'IN PROGRESS', 'ACKNOWLEDGED') THEN 'cv-b-progress'
                    WHEN L_STATUS = 'CLOSED'   THEN 'cv-b-closed'
                    WHEN L_STATUS = 'RESOLVED' THEN 'cv-b-resolved'
                    WHEN L_STATUS IN ('REJECTED', 'CANCELLED') THEN 'cv-b-danger'
                    ELSE 'cv-b-default'
                END;

            L_PRIO_CSS :=
                CASE C.PRIORITY_NO
                    WHEN 1 THEN 'cv-b-p1'
                    WHEN 2 THEN 'cv-b-p2'
                    WHEN 3 THEN 'cv-b-p3'
                    ELSE 'cv-b-p4'
                END;

            L_OVERDUE :=
                    C.REPORTED_DATE_TIME IS NOT NULL
                AND C.REPORTED_DATE_TIME < L_NOW - 1
                AND C.RESOLVED_DATE_TIME IS NULL
                AND C.CLOSED_DATE_TIME   IS NULL
                AND L_STATUS NOT IN ('RESOLVED', 'CLOSED', 'CANCELLED', 'REJECTED');

            L_RESPONSE :=
                CASE WHEN C.REPORTED_DATE_TIME IS NOT NULL
                      AND C.ACKNOWLEDGED_DATE_TIME IS NOT NULL
                     THEN FMT_MIN((C.ACKNOWLEDGED_DATE_TIME - C.REPORTED_DATE_TIME) * 1440)
                     ELSE '-' END;

            L_RESOLUTION :=
                CASE WHEN C.REPORTED_DATE_TIME IS NOT NULL
                      AND C.RESOLVED_DATE_TIME IS NOT NULL
                     THEN FMT_MIN((C.RESOLVED_DATE_TIME - C.REPORTED_DATE_TIME) * 1440)
                     ELSE '-' END;

            L_DOWNTIME :=
                CASE
                    WHEN C.DOWNTIME_MINUTES IS NOT NULL
                    THEN FMT_MIN(C.DOWNTIME_MINUTES)
                    WHEN C.PRODUCTION_IMPACT = 'FULL_STOP' AND C.REPORTED_DATE_TIME IS NOT NULL
                    THEN FMT_MIN((NVL(C.CLOSED_DATE_TIME, L_NOW) - C.REPORTED_DATE_TIME) * 1440)
                    WHEN C.PRODUCTION_IMPACT = 'PARTIAL_STOP' AND C.RESOLVED_DATE_TIME IS NOT NULL
                    THEN FMT_MIN((NVL(C.CLOSED_DATE_TIME, L_NOW) - C.RESOLVED_DATE_TIME) * 1440)
                    ELSE '-'
                END;

            ---------------- CARD ----------------
            PUT('<article class="cv-card" style="margin-bottom:24px">');

            -- Hero
            PUT('<header class="cv-hero"><div class="cv-hero-row">');
            PUT('<div>');
            PUT('<span class="cv-eyebrow">Maintenance Complaint</span>');
            PUT('<h3 class="cv-no">' || ESC(C.COMPLAINT_NO) || '</h3>');
            PUT('<span class="cv-sub">Reported by <strong>' || ESC(C.REPORTED_BY) ||
                '</strong> &middot; ' || ESC(FMT_DT(C.REPORTED_DATE_TIME)) || '</span>');
            PUT('</div>');
            PUT('<div class="cv-badges">');
            PUT(BADGE(REPLACE(L_STATUS, '_', ' '), L_STATUS_CSS));
            IF L_OVERDUE THEN
                PUT(BADGE('Overdue', 'cv-b-overdue'));
            END IF;
            IF NVL(C.REOPEN_COUNT, 0) > 0 THEN
                PUT(BADGE('Reopened x' || TO_CHAR(C.REOPEN_COUNT), 'cv-b-warn'));
            END IF;
            IF C.EXCEPTIONAL_CLOSURE = 'Y' THEN
                PUT(BADGE('Exceptional Closure', 'cv-b-warn'));
            END IF;
            PUT(BADGE(C.PRIORITY_NAME, L_PRIO_CSS));
            PUT('</div></div></header>');

            -- KPIs
            PUT('<div class="cv-kpis">');
            PUT(KPI('&#9201;', 'Response Time',   L_RESPONSE,   'cv-kpi-resp'));
            PUT(KPI('&#9989;', 'Resolution Time', L_RESOLUTION, 'cv-kpi-reso'));
            PUT(KPI('&#9888;', 'Downtime',        L_DOWNTIME,
                    CASE WHEN C.MACHINE_STOPPED = 'Y' THEN 'cv-kpi-down cv-kpi-alert'
                         ELSE 'cv-kpi-down' END));
            IF C.PARTS_COUNT > 0 THEN
                PUT(KPI('&#128176;', 'Total Parts Cost', FMT_NUM(C.TOTAL_COSTING), 'cv-kpi-cost'));
            END IF;
            PUT('</div>');

            -- Timeline
            PUT('<div class="cv-track">');
            PUT(STEP('Submitted',    C.REPORTED_DATE_TIME));
            PUT(STEP('Acknowledged', C.ACKNOWLEDGED_DATE_TIME));
            PUT(STEP('Resolved',     C.RESOLVED_DATE_TIME));
            IF L_STATUS IN ('CANCELLED', 'REJECTED') THEN
                PUT(STEP('Cancelled', C.REJECTION_DATE_TIME, 'is-cancelled'));
            ELSE
                PUT(STEP('Closed', C.CLOSED_DATE_TIME));
            END IF;
            PUT('</div>');

            -- Body
            PUT('<div class="cv-body">');

            PUT('<section class="cv-section"><h4 class="cv-sec-title">Location &amp; Machine</h4>');
            PUT('<div class="cv-grid">');
            PUT(FIELD('Department',      C.DEPARTMENT_NAME));
            PUT(FIELD('Production Line', C.LINE_NAME));
            PUT(FIELD('Machine',         C.MACHINE_NAME, 'span-2'));
            PUT('</div></section>');

            PUT('<section class="cv-section"><h4 class="cv-sec-title">Fault Details</h4>');
            PUT('<div class="cv-grid">');
            PUT(FIELD('Fault',    C.FAULT_NAME));
            PUT(FIELD('Priority', C.PRIORITY_NAME));
            PUT(FIELD('Production Impact', REPLACE(C.PRODUCTION_IMPACT, '_', ' ')));
            PUT(FIELD('Machine Stopped',
                      CASE C.MACHINE_STOPPED WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '-' END));
            PUT('</div>');

            PUT('<div class="cv-note"><span class="cv-lbl">Fault Description</span>' ||
                '<p>' || ESC_BR(C.FAULT_DESCRIPTION) || '</p></div>');

            IF C.REMARKS IS NOT NULL THEN
                PUT('<div class="cv-note note-plain"><span class="cv-lbl">Remarks</span>' ||
                    '<p>' || ESC_BR(C.REMARKS) || '</p></div>');
            END IF;

            IF C.REJECTION_REASON IS NOT NULL OR C.REJECTION_DATE_TIME IS NOT NULL THEN
                PUT('<div class="cv-note note-danger"><span class="cv-lbl">' ||
                    CASE WHEN L_STATUS IN ('CANCELLED', 'REJECTED')
                         THEN 'Cancellation Reason' ELSE 'Rejection Reason' END ||
                    '</span><p>' || ESC_BR(C.REJECTION_REASON) || '</p>' ||
                    CASE WHEN C.REJECTION_DATE_TIME IS NOT NULL
                         THEN '<span class="cv-lbl" style="margin-top:8px">Date: ' ||
                              ESC(FMT_DT(C.REJECTION_DATE_TIME)) || '</span>' END ||
                    '</div>');
            END IF;
            PUT('</section>');

            -- Change parts
            IF C.PARTS_COUNT > 0 THEN
                PUT('<section class="cv-section change-parts-section">');
                PUT('<h4 class="cv-sec-title">Change Parts</h4>');
                PUT('<div class="cv-table-wrap"><table class="cv-table">');
                PUT('<thead><tr><th>SR.#</th><th>Part</th>' ||
                    '<th class="num">Quantity</th><th class="num">Unit Price</th>' ||
                    '<th class="num">Total</th>' ||
                    CASE WHEN L_CAN_DEL THEN '<th class="act">Action</th>' END ||
                    '</tr></thead><tbody>');

                L_PART_NO := 0;
                FOR P IN (
                    SELECT MP.ID, MP.CHANGE_PARTS_NAME, MP.CHANGE_PARTS_PRICE, MP.CHANGE_PARTS_QTY
                      FROM MS_CHANGE_PART MP
                     WHERE MP.COMPLAINT_ID = C.COMPLAINT_ID
                     ORDER BY MP.ID
                )
                LOOP
                    L_PART_NO := L_PART_NO + 1;
                    PUT('<tr><td>' || TO_CHAR(L_PART_NO) || '</td>' ||
                        '<td>' || ESC(P.CHANGE_PARTS_NAME) || '</td>' ||
                        '<td class="num">' || ESC(FMT_NUM(P.CHANGE_PARTS_QTY)) || '</td>' ||
                        '<td class="num">' || ESC(FMT_NUM(P.CHANGE_PARTS_PRICE)) || '</td>' ||
                        '<td class="num">' ||
                            ESC(FMT_NUM(NVL(P.CHANGE_PARTS_QTY, 0) * NVL(P.CHANGE_PARTS_PRICE, 0))) ||
                        '</td>' ||
                        CASE WHEN L_CAN_DEL THEN
                            -- comp-del-btn kept so your existing JS click handler keeps working
                            '<td class="act"><button type="button" class="cv-del-btn comp-del-btn" ' ||
                            'data-part-id="' || TO_CHAR(P.ID) || '" ' ||
                            'data-part-name="' || APEX_ESCAPE.HTML_ATTRIBUTE(P.CHANGE_PARTS_NAME) || '" ' ||
                            'title="Delete this part">&#128465; Delete</button></td>'
                        END || '</tr>');
                END LOOP;

                PUT('</tbody><tfoot><tr>' ||
                    '<td colspan="4" class="num"><strong>Total Costing</strong></td>' ||
                    '<td class="num"><strong>' || ESC(FMT_NUM(C.TOTAL_COSTING)) || '</strong></td>' ||
                    CASE WHEN L_CAN_DEL THEN '<td></td>' END ||
                    '</tr></tfoot></table></div></section>');
            END IF;

            PUT('</div>'); -- cv-body

            -- Footer
            PUT('<footer class="cv-foot">');
            PUT('<span>Complaint ID: <strong>' || ESC(TO_CHAR(C.COMPLAINT_ID)) || '</strong></span>');
            PUT('<span>Complaint Date: <strong>' || ESC(FMT_DT(C.COMPLAINT_DATE)) || '</strong></span>');
            PUT('<span>Created: <strong>' || ESC(C.CREATED_BY) || '</strong> ' ||
                ESC(FMT_DT(C.CREATED_DATE)) || '</span>');
            PUT('<span>Updated: <strong>' || ESC(C.UPDATED_BY) || '</strong> ' ||
                ESC(FMT_DT(C.UPDATED_DATE)) || '</span>');
            PUT('</footer>');

            PUT('</article>');
        END LOOP;

        IF L_COUNT = 0 THEN
            PUT('<div class="cv-card"><div class="cv-empty"><b>&#128196;</b>' ||
                'No complaint found for <strong>' || ESC(TRIM(P_COMPLAINT_NO)) ||
                '</strong>.</div></div>');
        END IF;

        PUT('</div>');
        RETURN L_HTML;
    END GET_COMPLAINT_BY_NO;

END PKG_COMP_VIEW;
/
