# frozen_string_literal: true

namespace :data do
  desc 'Seed Ben Demo Conference 2025 for live class demo of conference + event duplication feature'
  task ben_demo: :environment do
    short_title = 'bendemo25'

    if Conference.exists?(short_title: short_title)
      puts "Conference '#{short_title}' already exists, skipping."
      next
    end

    puts 'Creating Ben Demo Conference 2025...'

    # --- Organization ---
    org = Organization.first_or_create!(name: 'Demo Organization')
    puts "Using organization: #{org.name}"

    # --- Conference ---
    conference = Conference.create!(
      title:       'Ben Demo Conference 2025',
      short_title: short_title,
      organization: org,
      start_date:  Date.new(2025, 10, 14),
      end_date:    Date.new(2025, 10, 16),
      start_hour:  9,
      end_hour:    18,
      timezone:    'America/Los_Angeles',
      description: 'Ben Demo Conference is a three-day gathering for software engineers, ' \
                   'architects, and technical leaders focused on modern web development, ' \
                   'distributed systems, and applied machine learning. ' \
                   'Attendees leave with practical techniques they can apply the following Monday.'
    )
    puts "Created conference: #{conference.title} (id=#{conference.id})"

    # --- Venue + Rooms ---
    venue = Venue.create!(
      conference: conference,
      name:       'Berkeley Convention Center',
      street:     '2026 Center St',
      city:       'Berkeley',
      country:    'US',
      postalcode: '94704'
    )
    puts "Created venue: #{venue.name}"

    room_data = [
      { name: 'Main Auditorium',   size: 800, order: 1 },
      { name: 'Hall A',            size: 300, order: 2 },
      { name: 'Hall B',            size: 300, order: 3 },
      { name: 'Workshop Room 1',   size: 80,  order: 4 },
      { name: 'Workshop Room 2',   size: 80,  order: 5 },
      { name: 'Networking Lounge', size: 200, order: 6 }
    ]

    rooms = room_data.map do |r|
      room = venue.rooms.create!(name: r[:name], size: r[:size], order: r[:order])
      puts "  Created room: #{room.name}"
      room
    end

    main_hall, hall_a, hall_b, workshop1, workshop2, _lounge = rooms

    # --- Program ---
    program = conference.program
    puts "Program id=#{program.id}"

    # --- CFP ---
    cfp = Cfp.create!(
      program:    program,
      cfp_type:   'events',
      start_date: Date.new(2025, 6, 1),
      end_date:   Date.new(2025, 8, 15),
      description: 'We welcome proposals for talks (30 min) and workshops (90 min) on ' \
                   'frontend engineering, backend systems, AI/ML in production, and DevOps.'
    )
    puts "Created CFP (events): #{cfp.start_date} - #{cfp.end_date}"

    # --- Event Types ---
    talk_type = program.event_types.create!(
      title:  'Talk',
      length: 30,
      color:  '#1F77B4',
      minimum_abstract_length: 100,
      maximum_abstract_length: 1000
    )
    workshop_type = program.event_types.create!(
      title:  'Workshop',
      length: 90,
      color:  '#FF7F0E',
      minimum_abstract_length: 100,
      maximum_abstract_length: 1000
    )
    puts "Created event types: Talk, Workshop"

    # --- Tracks ---
    track_data = [
      { name: 'Frontend Engineering',     short_name: 'frontend', color: '#1F77B4' },
      { name: 'Backend Systems',          short_name: 'backend',  color: '#2CA02C' },
      { name: 'AI & Machine Learning',    short_name: 'aiml',     color: '#9467BD' },
      { name: 'DevOps & Infrastructure',  short_name: 'devops',   color: '#D62728' }
    ]

    tracks = track_data.map do |t|
      track = program.tracks.create!(
        name:       t[:name],
        short_name: t[:short_name],
        color:      t[:color],
        cfp_active: false,
        state:      'new'
      )
      puts "  Created track: #{track.name}"
      track
    end

    fe_track, be_track, ai_track, ops_track = tracks

    # --- Speakers (users) ---
    speaker_data = [
      { name: 'Priya Mehta',       email: 'priya.mehta@bendemo25.example.com',    username: 'priyamehta_bd25' },
      { name: 'Carlos Rivera',     email: 'carlos.rivera@bendemo25.example.com',  username: 'crivera_bd25' },
      { name: 'Aisha Okonkwo',     email: 'aisha.okonkwo@bendemo25.example.com',  username: 'aokonkwo_bd25' },
      { name: 'James Whitfield',   email: 'james.whitfield@bendemo25.example.com',username: 'jwhitfield_bd25' },
      { name: 'Mei-Ling Zhang',    email: 'meiling.zhang@bendemo25.example.com',  username: 'mlzhang_bd25' },
      { name: 'Dmitri Volkov',     email: 'dmitri.volkov@bendemo25.example.com',  username: 'dvolkov_bd25' },
      { name: 'Sara Lindqvist',    email: 'sara.lindqvist@bendemo25.example.com', username: 'slindqvist_bd25' },
      { name: 'Kofi Asante',       email: 'kofi.asante@bendemo25.example.com',    username: 'kasante_bd25' }
    ]

    speakers = speaker_data.map do |s|
      user = User.find_or_initialize_by(email: s[:email])
      if user.new_record?
        user.name     = s[:name]
        user.username = s[:username]
        user.password = SecureRandom.hex(16)
        user.skip_confirmation!
        user.save!
      end
      puts "  Speaker: #{user.name}"
      user
    end

    priya, carlos, aisha, james, meiling, dmitri, sara, kofi = speakers

    # --- Events ---
    # Helper: create an event with speaker and schedule in one shot
    def make_event(program:, title:, subtitle:, abstract:, event_type:, track:, state: 'confirmed')
      program.events.create!(
        title:      title,
        subtitle:   subtitle,
        abstract:   abstract,
        event_type: event_type,
        track:      track,
        state:      state,
        language:   'English'
      )
    end

    events_list = []

    events_list << make_event(
      program:    program,
      title:      'React Server Components in Production: Lessons from Six Months',
      subtitle:   'Moving beyond the hype to real-world performance wins',
      abstract:   "React Server Components promised to simplify data-fetching and shrink client bundles. "\
                  "After six months running RSC in production at scale, we have real numbers to share. "\
                  "This talk walks through our migration from a traditional SPA, the gotchas we hit with "\
                  "streaming hydration, and the performance improvements we measured.\n\n"\
                  "We'll cover our deployment architecture, how we structured the client/server boundary, "\
                  "and the tooling we built to catch accidental client-side data leaks. Attendees will "\
                  "leave with a concrete checklist for adopting RSC in their own apps.",
      event_type: talk_type,
      track:      fe_track
    )

    events_list << make_event(
      program:    program,
      title:      'CSS Container Queries: The Composable Layout Revolution',
      subtitle:   'Writing components that respond to their context, not the viewport',
      abstract:   "For years we wrote breakpoints against the viewport even though components live inside "\
                  "containers of all shapes and sizes. Container queries finally let us write truly portable "\
                  "components. This session dives deep into `@container`, size units, style queries, and the "\
                  "new `:has()` pseudo-class that unlocks parent-aware styling.\n\n"\
                  "We'll refactor a real design system live on stage, replacing a tangle of media-query "\
                  "overrides with clean container-aware components. Expect plenty of before/after comparisons "\
                  "and a take-home demo repository.",
      event_type: talk_type,
      track:      fe_track
    )

    events_list << make_event(
      program:    program,
      title:      'State Machines for UI: Eliminating Impossible States',
      subtitle:   'Using XState and statechart theory to tame complex async flows',
      abstract:   "Async UIs accumulate impossible states faster than any other part of a frontend. "\
                  "Loading *and* error simultaneously. Data present but stale but also refreshing. "\
                  "This talk introduces statechart-driven UI as a discipline, not just a library choice.\n\n"\
                  "We'll model three real-world components — a multi-step form, an optimistic list, and "\
                  "a real-time dashboard — in XState, then show how the model drives tests, accessibility "\
                  "attributes, and Storybook stories automatically.",
      event_type: talk_type,
      track:      fe_track
    )

    events_list << make_event(
      program:    program,
      title:      'Building Resilient APIs with Rate Limiting and Backpressure',
      subtitle:   'Protecting your services without frustrating your callers',
      abstract:   "Rate limiting is easy to add and easy to get wrong. Naive fixed-window counters create "\
                  "thundering herd problems at window boundaries. Leaky buckets under-protect during bursts. "\
                  "This talk surveys the algorithmic options — token bucket, sliding log, GCRA — and explains "\
                  "when each is appropriate.\n\n"\
                  "We'll then look at the other side of the problem: how callers should handle 429s and "\
                  "propagate backpressure through async queues. Real Nginx, Redis, and Sidekiq configurations "\
                  "included.",
      event_type: talk_type,
      track:      be_track
    )

    events_list << make_event(
      program:    program,
      title:      'PostgreSQL Query Planner Deep Dive',
      subtitle:   'Understanding EXPLAIN ANALYZE output to stop guessing about slow queries',
      abstract:   "Most engineers treat the query planner as a black box and sprinkle indexes hopefully. "\
                  "This session demystifies EXPLAIN ANALYZE output line by line: what seq scan vs index scan "\
                  "actually means, when nested loop beats hash join, and why statistics matter more than indexes.\n\n"\
                  "We'll optimize a set of pathological queries live, covering partial indexes, expression "\
                  "indexes, covering indexes, and `pg_stat_statements`. You'll leave knowing exactly which "\
                  "knob to turn next time a query is slow.",
      event_type: talk_type,
      track:      be_track
    )

    events_list << make_event(
      program:    program,
      title:      'Event Sourcing Without the Ceremony',
      subtitle:   'Capturing intent and history in a Rails app without an event-sourcing framework',
      abstract:   "Event sourcing carries a reputation for complexity: CQRS projections, eventual consistency, "\
                  "saga orchestrators. But the core idea — record what happened, not just the final state — "\
                  "can be adopted incrementally in a plain Rails app.\n\n"\
                  "This talk presents a pragmatic subset: append-only domain events stored alongside your "\
                  "existing ActiveRecord models, a simple projection pattern for read models, and a "\
                  "migration strategy that doesn't require a big-bang rewrite. Three production case studies "\
                  "included.",
      event_type: talk_type,
      track:      be_track
    )

    events_list << make_event(
      program:    program,
      title:      'gRPC at the Edge: Streaming APIs for Real-Time Collaboration',
      subtitle:   'Replacing polling with bidirectional streams in a multi-tenant SaaS product',
      abstract:   "Our collaborative editing feature started with polling every two seconds. It ended with "\
                  "gRPC bidirectional streaming, a fanout service in Go, and latency measured in milliseconds. "\
                  "This talk narrates that journey honestly, including the dead ends.\n\n"\
                  "Topics include Protobuf schema design for change feeds, load-balancing long-lived streams "\
                  "behind a standard ALB, and the surprising operational differences between unary and "\
                  "streaming RPCs. Envoy proxy configuration snippets included.",
      event_type: talk_type,
      track:      be_track
    )

    events_list << make_event(
      program:    program,
      title:      'Practical RAG: Production Lessons from a Year of LLM Apps',
      subtitle:   'What retrieval-augmented generation actually looks like at scale',
      abstract:   "Retrieval-Augmented Generation is the first architectural pattern most teams reach for "\
                  "when adding LLMs to an existing product. After a year of running RAG in production across "\
                  "three different domains — legal documents, customer support, and internal knowledge bases — "\
                  "we have accumulated hard-won lessons about chunking strategies, embedding model selection, "\
                  "reranking, and eval.\n\n"\
                  "This talk shares what worked, what didn't, and the evals we wish we had written on day one. "\
                  "We'll also cover the infrastructure choices: pgvector vs Pinecone vs Weaviate and when the "\
                  "tradeoffs actually matter.",
      event_type: talk_type,
      track:      ai_track
    )

    events_list << make_event(
      program:    program,
      title:      'Fine-Tuning vs Prompting: When to Pay the Training Tax',
      subtitle:   'A decision framework for teams with limited ML resources',
      abstract:   "Every team running an LLM-powered feature faces the same question eventually: should we "\
                  "fine-tune, or can clever prompting get us there? The honest answer depends on data volume, "\
                  "latency requirements, cost targets, and how stable the task definition is.\n\n"\
                  "This talk lays out a structured decision framework and walks through three real cases where "\
                  "we made the call in each direction. We'll cover LoRA adapters, DPO for preference alignment, "\
                  "and the eval harness that let us compare fine-tuned models against prompt-engineered "\
                  "baselines with statistical rigor.",
      event_type: talk_type,
      track:      ai_track
    )

    events_list << make_event(
      program:    program,
      title:      'Responsible AI Deployment: Guardrails That Actually Work',
      subtitle:   'Moving beyond content filters to robust, testable safety pipelines',
      abstract:   "Bolting a content filter onto an LLM API call is not a safety strategy. This talk presents "\
                  "a layered approach to responsible AI deployment: input validation, output schema enforcement, "\
                  "semantic guardrails, confidence thresholds, and human-in-the-loop escalation paths.\n\n"\
                  "We'll look at each layer through the lens of testability — how do you write a regression "\
                  "test for a guardrail? — and share the incident post-mortems that drove each addition to "\
                  "our pipeline. Code examples in Python, tooling agnostic.",
      event_type: talk_type,
      track:      ai_track
    )

    events_list << make_event(
      program:    program,
      title:      'Kubernetes Cost Optimization: From $40k to $18k per Month',
      subtitle:   'Rightsizing, spot instances, and autoscaling without oncall nightmares',
      abstract:   "Cloud bills have a way of sneaking up on engineering teams. We reduced our monthly "\
                  "Kubernetes spend by 55% over six months without a single production incident caused by "\
                  "the cost work. This talk explains exactly how.\n\n"\
                  "We'll cover VPA and KEDA for rightsizing and event-driven autoscaling, our strategy for "\
                  "migrating stateless workloads to spot/preemptible instances with graceful drain handling, "\
                  "and the observability setup (Kubecost + custom Grafana dashboards) that made every "\
                  "decision visible to the team and to finance.",
      event_type: talk_type,
      track:      ops_track
    )

    events_list << make_event(
      program:    program,
      title:      'GitOps in Practice: ArgoCD Patterns for Multi-Tenant Clusters',
      subtitle:   'Structuring application of policy, tenancy, and continuous delivery at scale',
      abstract:   "GitOps promises a single source of truth for cluster state, but the path from one "\
                  "cluster and one team to many clusters and many teams reveals surprising complexity. "\
                  "This talk shares the ArgoCD patterns we've settled on after two years of operating "\
                  "a multi-tenant Kubernetes platform.\n\n"\
                  "Topics include ApplicationSet generators for tenant onboarding, the app-of-apps "\
                  "pattern vs flat repos, RBAC design that doesn't require a PhD in OPA, and our "\
                  "drift-detection and remediation runbook.",
      event_type: talk_type,
      track:      ops_track
    )

    events_list << make_event(
      program:    program,
      title:      'OpenTelemetry: Distributed Tracing Across a Polyglot Stack',
      subtitle:   'Instrumenting Ruby, Go, and Python services with a single observability backend',
      abstract:   "Distributed tracing sounds straightforward until you have services in three languages, "\
                  "two message brokers, and a legacy monolith that predates modern APM. This talk walks "\
                  "through our OpenTelemetry adoption: auto-instrumentation where it works, manual spans "\
                  "where it doesn't, and the collector pipeline that fans out to both Jaeger and our "\
                  "commercial APM vendor.\n\n"\
                  "We'll pay special attention to Rails and Sidekiq instrumentation quirks, baggage "\
                  "propagation across async boundaries, and the Grafana dashboards we built to surface "\
                  "the P99 latency regressions that matter.",
      event_type: talk_type,
      track:      ops_track
    )

    # Two workshops
    events_list << make_event(
      program:    program,
      title:      'Hands-On: Building Your First RAG Pipeline',
      subtitle:   'From a pile of PDFs to a working Q&A system in 90 minutes',
      abstract:   "In this hands-on workshop you will build a complete retrieval-augmented generation "\
                  "pipeline from scratch. Starting with raw PDF documents, you'll chunk and embed them "\
                  "into a pgvector database, wire up a retrieval step, and query an LLM with grounded "\
                  "context.\n\n"\
                  "Prerequisites: Python 3.11+, a laptop, and an OpenAI API key (free tier is fine). "\
                  "All starter code provided. By the end of the session you'll have a working system "\
                  "you understand end-to-end, plus the mental model to adapt it to your own data.",
      event_type: workshop_type,
      track:      ai_track
    )

    events_list << make_event(
      program:    program,
      title:      'Workshop: Zero-Downtime Deployments with Kamal and Health Checks',
      subtitle:   'Configure rolling deploys, readiness probes, and automated rollbacks',
      abstract:   "Kamal (formerly MRSK) makes Docker-based zero-downtime deploys accessible to teams "\
                  "without a Kubernetes budget. In this workshop we'll deploy a sample Rails app to a "\
                  "pair of cloud VMs, configure Traefik health checks, implement database migration "\
                  "strategies that don't lock tables, and trigger an automated rollback.\n\n"\
                  "You'll work in pairs on provided VMs. Bring a laptop with Docker installed. We'll "\
                  "finish with a war-game exercise: attendees attempt to break their partner's deploy "\
                  "pipeline while the other defends it.",
      event_type: workshop_type,
      track:      ops_track
    )

    events_list << make_event(
      program:    program,
      title:      'Accessibility Testing as Part of CI: No More Last-Minute Audits',
      subtitle:   'Integrating axe-core, VoiceOver testing, and keyboard navigation checks into your pipeline',
      abstract:   "Accessibility is consistently pushed to the end of projects and then rushed or cut. "\
                  "The fix is not more awareness — it's automation. This talk presents a layered "\
                  "accessibility testing strategy that catches the majority of issues before code review.\n\n"\
                  "We'll cover axe-core in Jest and Playwright, snapshot testing for ARIA trees, "\
                  "keyboard navigation test helpers, and the color-contrast linter that catches "\
                  "design-token regressions. Every technique shown has a corresponding CI configuration "\
                  "you can copy.",
      event_type: talk_type,
      track:      fe_track
    )

    puts "Created #{events_list.size} events"

    # --- Assign speakers to events ---
    speaker_assignments = [
      [events_list[0],  priya,   'speaker'],
      [events_list[1],  carlos,  'speaker'],
      [events_list[2],  aisha,   'speaker'],
      [events_list[3],  james,   'speaker'],
      [events_list[4],  meiling, 'speaker'],
      [events_list[5],  dmitri,  'speaker'],
      [events_list[6],  james,   'speaker'],
      [events_list[6],  sara,    'speaker'],  # co-speaker
      [events_list[7],  aisha,   'speaker'],
      [events_list[8],  kofi,    'speaker'],
      [events_list[9],  meiling, 'speaker'],
      [events_list[10], dmitri,  'speaker'],
      [events_list[11], carlos,  'speaker'],
      [events_list[12], sara,    'speaker'],
      [events_list[13], priya,   'speaker'],
      [events_list[14], kofi,    'speaker'],
      [events_list[15], james,   'speaker'],
      [events_list[15], aisha,   'speaker']   # co-speaker
    ]

    speaker_assignments.each do |ev, user, role|
      EventUser.create!(event: ev, user: user, event_role: role)
    end
    puts "Assigned speakers to events"

    # --- Schedule ---
    # Create a schedule and assign it as selected
    schedule = Schedule.create!(program: program)
    program.update_column(:selected_schedule_id, schedule.id)
    puts "Created schedule id=#{schedule.id}, set as selected"

    # Slot each event into a room + time. Three days, no double-booking.
    # Day 0 = Oct 14, Day 1 = Oct 15, Day 2 = Oct 16
    # Format: [event_index, day_offset, start_hour, room]
    slot_assignments = [
      # Day 1 - Oct 14
      [0,  0, 9,  main_hall],    # React Server Components
      [3,  0, 9,  hall_a],       # Resilient APIs
      [10, 0, 9,  hall_b],       # K8s Cost Optimization
      [1,  0, 10, main_hall],    # CSS Container Queries
      [4,  0, 10, hall_a],       # Postgres Query Planner
      [11, 0, 10, hall_b],       # GitOps ArgoCD
      [13, 0, 11, workshop1],    # RAG Workshop (90 min)
      [2,  0, 13, main_hall],    # State Machines for UI
      [5,  0, 13, hall_a],       # Event Sourcing
      [12, 0, 13, hall_b],       # OpenTelemetry
      [15, 0, 14, workshop2],    # Accessibility in CI
      # Day 2 - Oct 15
      [7,  1, 9,  main_hall],    # Practical RAG
      [6,  1, 9,  hall_a],       # gRPC streaming
      [8,  1, 10, main_hall],    # Fine-Tuning vs Prompting
      [9,  1, 11, main_hall],    # Responsible AI
      [14, 1, 11, workshop1],    # Kamal Workshop (90 min)
    ]

    base_date = conference.start_date

    slot_assignments.each do |ev_idx, day_offset, hour, room|
      event = events_list[ev_idx]
      start_time = (base_date + day_offset.days).to_time.in_time_zone(conference.timezone).change(hour: hour)
      EventSchedule.create!(
        event:    event,
        schedule: schedule,
        room:     room,
        start_time: start_time
      )
    end
    puts "Scheduled #{slot_assignments.size} events across 2 days"

    # --- Tickets ---
    # Conference#after_create creates one free registration ticket automatically.
    # Add paid tiers on top.
    conference.tickets.create!(
      title:              'Early Bird',
      description:        'Discounted rate for attendees who register before August 1, 2025.',
      price_cents:        14_900,
      price_currency:     'USD',
      registration_ticket: false,
      visible:            true
    )
    conference.tickets.create!(
      title:              'Regular',
      description:        'Standard conference admission including all sessions and meals.',
      price_cents:        29_900,
      price_currency:     'USD',
      registration_ticket: false,
      visible:            true
    )
    conference.tickets.create!(
      title:              'Student',
      description:        'Reduced-price ticket for full-time students. Student ID required at check-in.',
      price_cents:         7_500,
      price_currency:     'USD',
      registration_ticket: false,
      visible:            true
    )
    puts "Created 3 paid ticket tiers (Early Bird $149, Regular $299, Student $75)"
    puts "  (plus the automatic free registration ticket)"

    # --- Registration Period ---
    RegistrationPeriod.create!(
      conference: conference,
      start_date: Date.new(2025, 7, 1),
      end_date:   Date.new(2025, 10, 16)
    )
    puts "Created registration period: 2025-07-01 to 2025-10-16"

    # --- Attendee Registrations ---
    attendee_data = [
      { name: 'Alex Morgan',      email: 'alex.morgan@bendemo25.example.com',    username: 'amorgan_bd25' },
      { name: 'Fatima Al-Hassan', email: 'fatima.alhassan@bendemo25.example.com',username: 'falhassan_bd25' },
      { name: 'Tom Nakamura',     email: 'tom.nakamura@bendemo25.example.com',   username: 'tnakamura_bd25' },
      { name: 'Elena Petrov',     email: 'elena.petrov@bendemo25.example.com',   username: 'epetrov_bd25' },
      { name: 'Marcus Webb',      email: 'marcus.webb@bendemo25.example.com',    username: 'mwebb_bd25' },
      { name: 'Nadia Osei',       email: 'nadia.osei@bendemo25.example.com',     username: 'nosei_bd25' },
      { name: 'Ryan Castellano',  email: 'ryan.castellano@bendemo25.example.com',username: 'rcastellano_bd25' }
    ]

    attendee_data.each do |a|
      user = User.find_or_initialize_by(email: a[:email])
      if user.new_record?
        user.name     = a[:name]
        user.username = a[:username]
        user.password = SecureRandom.hex(16)
        user.skip_confirmation!
        user.save!
      end
      Registration.create!(conference: conference, user: user)
      puts "  Registered attendee: #{user.name}"
    end

    # --- Splashpage ---
    Splashpage.create!(
      conference:           conference,
      public:               true,
      include_tracks:       true,
      include_program:      true,
      include_venue:        true,
      include_tickets:      true,
      include_registrations: true,
      include_cfp:          false,
      include_sponsors:     false,
      include_lodgings:     false,
      include_social_media: false,
      include_booths:       false
    )
    puts "Created splashpage (public)"

    puts ''
    puts '=== Ben Demo Conference 2025 seeded successfully ==='
    puts "  Conference id: #{conference.id}"
    puts "  URL slug:      #{short_title}"
    puts "  Tracks:        #{tracks.size}"
    puts "  Rooms:         #{rooms.size}"
    puts "  Events:        #{events_list.size}"
    puts "  Scheduled:     #{slot_assignments.size}"
    puts "  Tickets:       #{conference.tickets.count} (including free registration ticket)"
    puts "  Registrations: #{conference.registrations.count}"
    puts ''
    puts "Run with: rake data:ben_demo"
  end
end
