  $ ../run.sh
  pass valid/and_dot_key_mask
  pass valid/binding_table
  pass valid/button_state
  pass valid/change_active_pointer_grab
  pass valid/check_mask_event
  pass valid/create_window
  pass valid/device_mask_as_selection
  pass valid/difference_event_masks
  pass valid/difference_key_mask
  pass valid/do_not_propagate
  pass valid/do_not_propagate_or_exposure
  pass valid/event_mask_or_pointer_mask
  pass valid/extend_selection
  pass valid/fold_modifiers
  pass valid/function_argument_shared
  pass valid/grab_button
  pass valid/grab_button_any_modifier_events
  pass valid/grab_from_state
  pass valid/grab_key_any_modifier
  pass valid/grab_key_modifiers
  pass valid/grab_key_no_modifier
  pass valid/grab_numlock_variants
  pass valid/grab_pointer
  pass valid/key_mask_or_lock
  pass valid/pointer_mask_as_selection
  pass valid/pointer_mask_or_exposure
  pass valid/pointer_or_device_selection
  pass valid/query_pointer
  pass valid/select_input
  pass valid/send_event
  pass valid/shared_event_mask
  pass valid/sowm_clean_compare
  pass valid/state_test_key_mask
  pass valid/test_event_masks
  pass valid/test_key_mask
  pass valid/ungrab
  pass valid/xkb_group
  pass invalid/and_dot_any_modifier_union
  Error: This expression has type ([> `Key ], 'a, Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  FAIL invalid/change_active_pointer_grab_exposure: accepted
  FAIL invalid/create_window_do_not_propagate: accepted
  pass invalid/do_not_propagate_enter
  Error: The value enterWindowMask has type
         The second variant type does not allow tag(s) `PointerEvent
  pass invalid/do_not_propagate_selection
  Error: The field access attributes.your_event_mask has type
         The second variant type does not allow tag(s) `Event, `PointerEvent
  pass invalid/grab_button_any_modifier_union
  Error: The value anyModifier has type ([> `Key ], 'a, Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  pass invalid/grab_button_exposure
  Error: The value exposureMask has type ([ `Ev ], [> `Event ], 'a) Mask.mask
         The second variant type does not allow tag(s) `Event
  pass invalid/grab_button_modifier_button
  Error: This expression has type ([> `Button | `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Button
  pass invalid/grab_key_any_modifier_union
  Error: The value anyModifier has type ([> `Key ], 'a, Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  pass invalid/grab_key_button
  Error: This expression has type ([> `Button | `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Button
  pass invalid/grab_key_query_pointer
  Error: This expression has type
         The second variant type does not allow tag(s) `Button
  pass invalid/grab_key_state
  Error: The field access ev.state has type
         The second variant type does not allow tag(s) `Button
  FAIL invalid/grab_pointer_exposure: accepted
  FAIL invalid/grab_pointer_key_event: accepted
  FAIL invalid/shared_event_mask: accepted
  pass invalid/ungrab_button_any_modifier_union
  Error: The value anyModifier has type ([> `Key ], 'a, Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  pass invalid/ungrab_key_button
  Error: This expression has type ([> `Button | `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Button
  pass misuse/and_dot_event_modifier
  Error: The value keyPressMask has type
         The second variant type does not allow tag(s) `Ev
  pass misuse/and_dot_state_event
  Error: The value exposureMask has type ([> `Ev ], [> `Event ], 'a) Mask.mask
         The second variant type does not allow tag(s) `Ev
  pass misuse/button_state_as_selection
  Error: The field access ev.state has type
         These two variant types have no intersection
  pass misuse/check_mask_event_modifier
  Error: The value shiftMask has type ([> `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Key
  pass misuse/create_window_modifier
  Error: The value controlMask has type ([> `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Key
  FAIL misuse/grab_button_structure: accepted
  pass misuse/grab_key_event
  Error: The value keyPressMask has type
         The second variant type does not allow tag(s) `Ev
  pass misuse/grab_key_int
  Error: The constant 0x40 has type int but an expression was expected of type
         ([ `Key ], 'a, 'b) Mask.mask
  pass misuse/grab_pointer_button_mask
  Error: The value button1Mask has type ([> `Button ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Button
  pass misuse/grab_pointer_structure
  Error: The value structureNotifyMask has type
         The second variant type does not allow tag(s) `Event
  pass misuse/select_input_any_modifier
  Error: The value anyModifier has type ([> `Key ], 'a, Mask.alone) Mask.mask
         The second variant type does not allow tag(s) `Key
  pass misuse/select_input_modifier
  Error: The value shiftMask has type ([> `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Key
  pass misuse/send_event_modifier
  Error: The value mod4Mask has type ([> `Key ], 'a, 'b) Mask.mask
         The second variant type does not allow tag(s) `Key
  pass misuse/ungrab_key_event
  Error: The value keyPressMask has type
         The second variant type does not allow tag(s) `Ev
  
  valid: 37/37
  invalid: 12/17
  misuse: 13/14
