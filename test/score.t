  $ ../run.sh
  pass valid/binding_table
  pass valid/button_state
  pass valid/change_active_pointer_grab
  pass valid/check_mask_event
  pass valid/create_window
  pass valid/do_not_propagate
  pass valid/extend_selection
  pass valid/grab_button
  pass valid/grab_from_state
  pass valid/grab_key_any_modifier
  pass valid/grab_key_modifiers
  pass valid/grab_key_no_modifier
  pass valid/grab_numlock_variants
  pass valid/grab_pointer
  pass valid/query_pointer
  pass valid/select_input
  pass valid/send_event
  pass valid/shared_event_mask
  pass valid/sowm_clean_compare
  pass valid/ungrab
  pass valid/xkb_group
  FAIL invalid/change_active_pointer_grab_exposure: accepted
  FAIL invalid/create_window_do_not_propagate: accepted
  FAIL invalid/do_not_propagate_enter: accepted
  FAIL invalid/do_not_propagate_selection: accepted
  FAIL invalid/grab_button_any_modifier_union: accepted
  FAIL invalid/grab_button_exposure: accepted
  FAIL invalid/grab_button_modifier_button: accepted
  FAIL invalid/grab_key_any_modifier_union: accepted
  FAIL invalid/grab_key_button: accepted
  FAIL invalid/grab_key_query_pointer: accepted
  FAIL invalid/grab_key_state: accepted
  FAIL invalid/grab_pointer_exposure: accepted
  FAIL invalid/grab_pointer_key_event: accepted
  FAIL invalid/shared_event_mask: accepted
  FAIL invalid/ungrab_button_any_modifier_union: accepted
  FAIL invalid/ungrab_key_button: accepted
  FAIL misuse/button_state_as_selection: accepted
  FAIL misuse/check_mask_event_modifier: accepted
  FAIL misuse/create_window_modifier: accepted
  FAIL misuse/grab_button_structure: accepted
  FAIL misuse/grab_key_event: accepted
  FAIL misuse/grab_key_int: accepted
  FAIL misuse/grab_pointer_button_mask: accepted
  FAIL misuse/grab_pointer_structure: accepted
  FAIL misuse/select_input_any_modifier: accepted
  FAIL misuse/select_input_modifier: accepted
  FAIL misuse/send_event_modifier: accepted
  FAIL misuse/ungrab_key_event: accepted
  
  valid: 21/21
  invalid: 0/16
  misuse: 0/12
