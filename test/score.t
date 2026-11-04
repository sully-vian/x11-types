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
  pass invalid/change_active_pointer_grab_exposure
  Error: This expression has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass invalid/create_window_do_not_propagate
  Error: This expression has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Device
  pass invalid/do_not_propagate_enter
  Error: The value enterWindowMask has type
         The first variant type does not allow tag(s) `Device
  pass invalid/do_not_propagate_selection
  Error: The field access attributes.your_event_mask has type
         The first variant type does not allow tag(s) `Device
  pass invalid/grab_button_any_modifier_union
  Error: The value anyModifier has type ([< `Grab ], Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  pass invalid/grab_button_exposure
  Error: The value exposureMask has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass invalid/grab_button_modifier_button
  Error: This expression has type ([< `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Grab
  pass invalid/grab_key_any_modifier_union
  Error: The value anyModifier has type ([< `Grab ], Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  pass invalid/grab_key_button
  Error: This expression has type ([< `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Grab
  pass invalid/grab_key_query_pointer
  Error: This expression has type
         The first variant type does not allow tag(s) `Grab
  pass invalid/grab_key_state
  Error: The field access ev.state has type
         The first variant type does not allow tag(s) `Grab
  pass invalid/grab_pointer_exposure
  Error: This expression has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass invalid/grab_pointer_key_event
  Error: This expression has type ([< `Device | `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass invalid/shared_event_mask
  Error: The value m has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass invalid/ungrab_button_any_modifier_union
  Error: The value anyModifier has type ([< `Grab ], Mask.alone) Mask.mask
         Type Mask.alone is not compatible with type Mask.union
  pass invalid/ungrab_key_button
  Error: This expression has type ([< `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Grab
  pass misuse/button_state_as_selection
  Error: The field access ev.state has type
         The first variant type does not allow tag(s) `Event
  pass misuse/check_mask_event_modifier
  Error: The value shiftMask has type ([< `Grab | `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Event
  pass misuse/create_window_modifier
  Error: The value controlMask has type ([< `Grab | `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Event
  pass misuse/grab_button_structure
  Error: This expression has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass misuse/grab_key_event
  Error: The value keyPressMask has type ([< `Device | `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Grab
  pass misuse/grab_key_int
  Error: The constant 0x40 has type int but an expression was expected of type
         ([> `Grab ], 'a) Mask.mask
  pass misuse/grab_pointer_button_mask
  Error: The value button1Mask has type ([< `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass misuse/grab_pointer_structure
  Error: The value structureNotifyMask has type ([< `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Pointer
  pass misuse/select_input_any_modifier
  Error: The value anyModifier has type ([< `Grab ], Mask.alone) Mask.mask
         The first variant type does not allow tag(s) `Event
  pass misuse/select_input_modifier
  Error: The value shiftMask has type ([< `Grab | `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Event
  pass misuse/send_event_modifier
  Error: The value mod4Mask has type ([< `Grab | `State ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Event
  pass misuse/ungrab_key_event
  Error: The value keyPressMask has type ([< `Device | `Event ], 'a) Mask.mask
         The first variant type does not allow tag(s) `Grab
  
  valid: 21/21
  invalid: 16/16
  misuse: 12/12
